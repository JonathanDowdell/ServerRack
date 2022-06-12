//
//  Commands.swift
//  Server Rack
//
//  Created by Jonathan Dowdell on 5/25/22.
//

import Foundation

enum Commands: String {
    case SysHwmonTemp = "cat /sys/class/hwmon/hwmon*/temp*"
    
    case TopTop = "top -bn1 | sed -n '/top -/p'"
    case TopCPUCore = "top -1bcn1 -w512 | sed -n '/^%Cpu/p'"
    case TopCPU = "top -bn1 | sed -n '/Cpu/p'"
    case TopMem = "top -bn1 | sed -n '/Mem.:/p'"
    case TopSwap = "top -bn1 | sed -n '/Swap*:/p'"
    
    case ProcNetDev = "cat /proc/net/dev | awk '{print $1, \" - \",  $2, \"down\", $10, \"up\", \"split\"}'"
    
    case DiskFree = "df -BM | sed '/^dev/d' | sed '/tmpfs*/d' | awk '{print $1, \"|\", $2, \"|\", $3, \"|\", $4, \"|\", $5, \"|\", $6, \"split\"}' | sed '/Filesystem/d'"
    
    case ProcDiskStats = "cat /proc/diskstats | awk '{ print $3, $6, $10, \"split\" }' | sed '/ram*\\|loop*/d'"
}

enum Unit {
    case MiB
    case MB
    case GiB
    case GB
}
