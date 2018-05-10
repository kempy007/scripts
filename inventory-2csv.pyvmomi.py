#!/usr/bin/env python
# VMware vSphere Python SDK
# Copyright (c) 2008-2015 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Python program for listing the vms on an ESX / vCenter host
"""

from __future__ import print_function

from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim

import argparse
import atexit
import getpass
import ssl

import csv
import pdb # enable debug
data = ['"VmName","Path","GuestOS","Annotation","State","IP","HostName","uuid","instanceUuid","netAdapter","MAC Address","PortGroup"']
csvfile = "vm-inv-export.csv"

def GetArgs():
   """
   Supports the command-line arguments listed below.
   """
   parser = argparse.ArgumentParser(
       description='Process args for retrieving all the Virtual Machines')
   parser.add_argument('-s', '--host', required=True, action='store',
                       help='Remote host to connect to')
   parser.add_argument('-o', '--port', type=int, default=443, action='store',
                       help='Port to connect on')
   parser.add_argument('-u', '--user', required=True, action='store',
                       help='User name to use when connecting to host')
   parser.add_argument('-p', '--password', required=False, action='store',
                       help='Password to use when connecting to host')
   args = parser.parse_args()
   return args


def PrintVmInfo(vm, depth=1):
   """
   Print information for a particular virtual machine or recurse into a folder
   or vApp with depth protection
   """
   maxdepth = 10

   # if this is a group it will have children. if it does, recurse into them
   # and then return
   if hasattr(vm, 'childEntity'):
      if depth > maxdepth:
         return
      vmList = vm.childEntity
      for c in vmList:
         PrintVmInfo(c, depth+1)
      return

   # if this is a vApp, it likely contains child VMs
   # (vApps can nest vApps, but it is hardly a common usecase, so ignore that)
   if isinstance(vm, vim.VirtualApp):
      vmList = vm.vm
      for c in vmList:
         PrintVmInfo(c, depth + 1)
      return

   summary = vm.summary
   print("Name       : ", summary.config.name)
   print("Path       : ", summary.config.vmPathName)
   print("Guest      : ", summary.config.guestFullName)
   
   notes = summary.config.annotation
   if summary.config.annotation != None:
     print("Annotation : ", summary.config.annotation) #
   else: 
     notes = ""
     print("Annotation : ", "")
	 
   print("State      : ", summary.runtime.powerState)
   
   ip = summary.guest.ipAddress
   if ip != None and ip != "":
     print("IP         : ", ip) #
   else: 
     ip = ""
     print("IP         : ", "")

   host = summary.guest.hostName	 
   if summary.guest.hostName != None:
     print("HostName   : ", summary.guest.hostName) #
   else: 
     host = ""
     print("HostName   : ", "")
	 
   if summary.runtime.question != None:
     print("Question   : ", summary.runtime.question.text) # nothing shows
   else: 
     print("Question   : ", "")


#      pdb.set_trace() 
   netAdapt = []
   MAC = []
   pgroup = []   
   for dev in vm.config.hardware.device:
        if isinstance(dev, vim.vm.device.VirtualEthernetCard):
            dev_backing = dev.backing
            portGroup = None
            vlanId = None
            vSwitch = None
            if hasattr(dev_backing, 'port'):
                portGroupKey = dev.backing.port.portgroupKey
                dvsUuid = dev.backing.port.switchUuid
                try:
                    dvs = content.dvSwitchManager.QueryDvsByUuid(dvsUuid)
                except:
                    portGroup = "** Error: DVS not found **"
                    vlanId = "NA"
                    vSwitch = "NA"
                else:
                    pgObj = dvs.LookupDvPortGroup(portGroupKey)
                    portGroup = pgObj.config.name
                    vlanId = str(pgObj.config.defaultPortConfig.vlan.vlanId)
                    vSwitch = str(dvs.name)
            else:
                portGroup = dev.backing.network.name
                #vmHost = vm.runtime.host
                # global variable hosts is a list, not a dict
                #host_pos = hosts.index(vmHost)
                #viewHost = hosts[host_pos]
                # global variable hostPgDict stores portgroups per host
                #pgs = hostPgDict[viewHost]
                #for p in pgs:
                #    if portGroup in p.key:
                #        vlanId = str(p.spec.vlanId)
                #        vSwitch = str(p.spec.vswitchName)
            if portGroup is None:
                portGroup = 'NA'
            if vlanId is None:
                vlanId = 'NA'
            if vSwitch is None:
                vSwitch = 'NA'
            print('\t' + dev.deviceInfo.label + ' -> ' + dev.macAddress +
#                  ' @ ' + vSwitch + '->' +
                  portGroup )
#                  +' (VLAN ' + vlanId + ')')
            netAdapt.append(dev.deviceInfo.label+'\r\n')
            MAC.append(dev.macAddress+'\r\n')
            pgroup.append(portGroup+'\r\n')
   # vswitch,vlanid all none
   data.append('"'+summary.config.name+'","'+summary.config.vmPathName+'","'+summary.config.guestFullName+'","'+notes+'","'+summary.runtime.powerState+'","'+ip+'","'+host+'","'+vm.summary.config.uuid+'","'+vm.summary.config.instanceUuid+'","'+''.join(netAdapt)+'","'+''.join(MAC)+'","'+''.join(pgroup)+'"')
   pdb.set_trace()
   print("")

				  
def main():
   """
   Simple command-line program for listing the virtual machines on a system.
   """
   args = GetArgs()
   if args.password:
      password = args.password
   else:
      password = getpass.getpass(prompt='Enter password for host %s and '
                                        'user %s: ' % (args.host,args.user))

   context = None
   if hasattr(ssl, '_create_unverified_context'):
      context = ssl._create_unverified_context()
   si = SmartConnect(host=args.host,
                     user=args.user,
                     pwd=password,
                     port=int(args.port),
                     sslContext=context)
   if not si:
       print("Could not connect to the specified host using specified "
             "username and password")
       return -1

   atexit.register(Disconnect, si)

   content = si.RetrieveContent()
   for child in content.rootFolder.childEntity:
      if hasattr(child, 'vmFolder'):
         datacenter = child
         vmFolder = datacenter.vmFolder
         vmList = vmFolder.childEntity
         for vm in vmList:
            PrintVmInfo(vm)
   with open(csvfile, "w") as output:
     writer = csv.writer(output, lineterminator='\n')
     for row in data:
       writer.writerow([row])
   return 0

# Start program
if __name__ == "__main__":
   main()
