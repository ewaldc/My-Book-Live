#!/bin/sh
CPP_OPTS="-nostdinc -I ../arch/powerpc/boot/dts -I ../arch/powerpc/boot/dts/include -x assembler-with-cpp  -undef -D__DTS__"
DTC_COMMAND="cpp $CPP_OPTS apollo3g.dts | dtc -O dtb -I dts -o "

do_dtc(){
	cpp $CPP_OPTS $1.dts | dtc -O dtb -I dts -o $1.dtb - || chmod 644 $1.dtb
}

# Add your source files here
do_dtc apollo3g
do_dtc apollo3g_duo


exit
#cpp -nostdinc -x assembler-with-cpp -I ../arch/powerpc/boot/dts -I ../arch/powerpc/boot/dts/include -undef -D__DTS__ -o Apollo3g.tmp apollo3g.dts
#./scripts/dtc/dtc -O dtb -idts/apollo3g.dts --space 16384 -o dts/apollo3g.dtb Apollo3g.tmp
#dtc -O dtb -iapollo3g.dts -o apollo3g.dtb Apollo3g.tmp
#rm -f Apollo3g.tmp
#./scripts/dtc/dtc -I dts -O dtb arch/powerpc/boot/dts/apollo3g.dts -o apollo3g.dtb
#./scripts/dtc/dtc -I dtb -O dts apollo3g.dtb
#cpp -nostdinc -x assembler-with-cpp -I ../arch/powerpc/boot/dts -I ../arch/powerpc/boot/dts/include -undef -D__DTS__ -o Apollo3g.tmp apollo3g_duo.dts
#dtc -O dtb -iapollo3g.dts -o apollo3g_duo.dtb Apollo3g.tmp
#dtc -O dtb -I dts -o apollo3g_eco.dtb apollo3g_eco.dts
