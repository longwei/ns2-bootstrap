# Parameters: seed

Mac/802_11 set CWMin_               15
Mac/802_11 set CWMax_               1023
Mac/802_11 set SlotTime_            0.000009
Mac/802_11 set SIFS_                0.000016
Mac/802_11 set ShortRetryLimit_     7
Mac/802_11 set LongRetryLimit_      4
Mac/802_11 set PreambleLength_      60
Mac/802_11 set PLCPHeaderLength_    60
Mac/802_11 set PLCPDataRate_        6.0e6
Mac/802_11 set RTSThreshold_        2000
Mac/802_11 set basicRate_           6.0e6
Mac/802_11 set dataRate_            6.0e6

Mac/802_11Ext set CWMin_            15
Mac/802_11Ext set CWMax_            1023
Mac/802_11Ext set SlotTime_         0.000009
Mac/802_11Ext set SIFS_             0.000016
Mac/802_11Ext set ShortRetryLimit_  7
Mac/802_11Ext set LongRetryLimit_   4
Mac/802_11Ext set HeaderDuration_   0.000020 
Mac/802_11Ext set SymbolDuration_   0.000004
Mac/802_11Ext set BasicModulationScheme_ 0
Mac/802_11Ext set use_802_11a_flag_ true
Mac/802_11Ext set RTSThreshold_     2000
Mac/802_11Ext set MAC_DBG           0

Phy/WirelessPhy set CSThresh_       6.30957e-12
Phy/WirelessPhy set Pt_             0.001
Phy/WirelessPhy set freq_           5.18e9
Phy/WirelessPhy set L_              1.0
Phy/WirelessPhy set RXThresh_       3.652e-10
Phy/WirelessPhy set bandwidth_      20e6
Phy/WirelessPhy set CPThresh_       10.0

Phy/WirelessPhyExt set CSThresh_           6.30957e-12
Phy/WirelessPhyExt set Pt_                 0.001
Phy/WirelessPhyExt set freq_               5.18e9
Phy/WirelessPhyExt set noise_floor_        2.51189e-13
Phy/WirelessPhyExt set L_                  1.0
Phy/WirelessPhyExt set PowerMonitorThresh_ 2.10319e-12
Phy/WirelessPhyExt set HeaderDuration_     0.000020
Phy/WirelessPhyExt set BasicModulationScheme_ 0
Phy/WirelessPhyExt set PreambleCaptureSwitch_ 1
Phy/WirelessPhyExt set DataCaptureSwitch_  0
Phy/WirelessPhyExt set SINR_PreambleCapture_ 2.5118
Phy/WirelessPhyExt set SINR_DataCapture_   100.0
Phy/WirelessPhyExt set trace_dist_         1e6
Phy/WirelessPhyExt set PHY_DBG_            0
Phy/WirelessPhyExt set CPThresh_           0 ;# not used at the moment
Phy/WirelessPhyExt set RXThresh_           0 ;# not used at the moment


#=====================================================================

#configure RF model parameters
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

Propagation/Nakagami set use_nakagami_dist_ false
Propagation/Nakagami set gamma0_ 2.0
Propagation/Nakagami set gamma1_ 2.0
Propagation/Nakagami set gamma2_ 2.0

Propagation/Nakagami set d0_gamma_ 200
Propagation/Nakagami set d1_gamma_ 500

Propagation/Nakagami set m0_  1.0
Propagation/Nakagami set m1_  1.0
Propagation/Nakagami set m2_  1.0

Propagation/Nakagami set d0_m_ 80
Propagation/Nakagami set d1_m_ 200

#=======================================================================


set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround

set val(netif)      Phy/WirelessPhyExt
set val(mac)        Mac/802_11Ext
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(x)          500   	;# X dimension of the topography
set val(y)          500   	;# Y dimension of the topography
set val(ifqlen)     20           ;# max packet in ifq
set val(ni)         1         ;# number of interrupt node
set val(nn)         3         ;# how many nodes total
set val(rtg)        DumbAgent
set val(stop)       2000          ;# simulation time
# =====================================================================
set val(MayShare)	    2
set val(MayBeacon)	    3
set val(MayAccept)	    4
set val(OkNeighbor)	    5
set val(Generic)		6

set val(undefined)	    -1
set val(false)			0
set val(true)		    1
set val(bcnInt) 		1
set val(itrptInt) 		0.00001
#set val(movement) 	"movement_file"
#
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

global defaultRNG
$defaultRNG seed 1234

set ns_		[new Simulator]
set topo	[new Topography]
#set tracefd	stdout
set tracefd     [open trace.tr w]
$ns_ trace-all $tracefd
$ns_ use-newtrace

$topo load_flatgrid $val(x) $val(y)
set god_ [create-god $val(nn)]
$god_ off

set chan [new $val(chan)]
$ns_ node-config -adhocRouting $val(rtg) \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -channel $chan \
		         -topoInstance $topo \
		         -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF \
                 -phyTrace OFF

for {set j 0} {$j < $val(ni) } {incr j} {
    set ID_($j) $j
    set node_($j) [$ns_ node]
    $node_($j) set id_  $ID_($j)
    $node_($j) set address_ $ID_($j)
    $node_($j) set X_ 100
    $node_($j) set Y_ 100
    $node_($j) set Z_ 0
    $node_($j) nodeid $ID_($j)

    set agent_($j) [new Agent/PBC]
    $ns_ attach-agent $node_($j)  $agent_($j)
    $agent_($j) set Pt_ 1
    $agent_($j) set payloadSize 100000
    $agent_($j) set peroidcaBroadcastInterval $val(itrptInt) 
    $agent_($j) set peroidcaBroadcastVariance $val(itrptInt)
    $agent_($j) set modulationScheme 1

    $agent_($j) set ni 1
    $agent_($j) set avgLoss 0.0
    $agent_($j) set alpha 0.02
    $agent_($j) set dynaTimerSet 0

    $agent_($j) set halfTimeout 3
    $agent_($j) set fullTimeout 4
    $agent_($j) set upkeepTimeout 2 

    $agent_($j) SetID $ID_($j)
    $agent_($j) SetNN $val(nn)
    $ns_ at $val(stop).0 "$node_($j) reset";
    #$agent_($j) CreatePolicy $val(MayBeacon) $j 0.0 0.0 $val(stop) $val(true) $val(itrptInt) 
}

for {set i $val(ni)} {$i < $val(nn) } {incr i} {
    set ID_($i) $i
    set node_($i) [$ns_ node]
    $node_($i) set id_  $ID_($i)
    $node_($i) set address_ $ID_($i)
    $node_($i) set X_ [expr $i * 100 + 100]
    $node_($i) set Y_ 100
    $node_($i) set Z_ 0
    $node_($i) nodeid $ID_($i)

    set agent_($i) [new Agent/PBC]
    $ns_ attach-agent $node_($i)  $agent_($i)
    $agent_($i) set Pt_ 1e-4
    $agent_($i) set payloadSize 1000
    $agent_($i) set peroidcaBroadcastInterval $val(bcnInt)
    $agent_($i) set peroidcaBroadcastVariance 1
    $agent_($i) set modulationScheme 1

    $agent_($i) set avgLoss 0.1
    $agent_($i) set alpha 0.05
    $agent_($i) set dynaTimerSet 0

    $agent_($i) set halfTimeout 3
    $agent_($i) set fullTimeout 4
    $agent_($i) set upkeepTimeout 2 

    $agent_($i) SetID $ID_($i)
    $agent_($i) SetNN $val(nn)
    $ns_ at $val(stop).0 "$node_($i) reset";
}

#add policy
for {set i 0} { $i < $val(nn) } {incr i} {
	$agent_($i) CreatePolicy $val(MayBeacon) $i 0.0 0.0 $val(stop) $val(true) $val(bcnInt) 
	for {set j 0} {$j < $val(nn)} {incr j}  {	
		if {$j != $i} {
			$agent_($i) CreatePolicy $val(MayShare) $i 0.7 0.0 $val(stop) $j $val(true)
			$agent_($i) CreatePolicy $val(MayAccept) $i 0.7 0.0 $val(stop) $j $val(true)
			#$agent_($i) CreatePolicy $val(OkNeighbor) $i 0.7 0.0 $val(stop) $j $val(undefined)
			$agent_($i) CreatePolicy $val(OkNeighbor) $i 0.7 0.0 $val(stop) $j $val(true)  
		}
	}
}

$ns_ at $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $val(stop).0003 "$ns_ flush-trace"
puts "Starting Simulation..."
$ns_ run


