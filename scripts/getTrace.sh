#!/bin/bash
rm -r temptrace
mkdir temptrace
zcat m5out/trace.log.gz | grep recvTimingReq | sed 's/://g' | sed 's/^[ ]*//' | sed 's/ /,/g' | awk -F',' '{print $1","$5","$7","$10}' > temptrace/mem_trace
zcat m5out/trace.log.gz | grep Address | awk '{print $1","$4","$6","$8","$10}' | sed 's/://' > temptrace/dram_trace

echo -n "Number of memory accesses: " 
cat temptrace/mem_trace | grep -E '*' -c
echo -n "Number of PTWalk accesses: "
cat temptrace/mem_trace | grep 'PTWalk' -c
echo -n "Number of OtherDRAM accesses: "
cat temptrace/mem_trace | grep 'OtherDRAMAccess' -c
