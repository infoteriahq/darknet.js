#!/usr/bin/env bash
if [ ! -d darknet ]; then
    git clone https://github.com/AlexeyAB/darknet --depth=1;

    if [ $? -ne 0 ]; then
        echo "Could not clone darknet repo";
        exit 1;
    fi
fi

# dive in the darknet folder and make
cd darknet

# look for exported variables for GPU and CUDNN
GPU="${DARKNET_BUILD_WITH_GPU:-0}";
CUDNN="${DARKNET_BUILD_WITH_CUDNN:-0}";
OPENCV="${DARKNET_BUILD_WITH_OPENCV:-0}";
OPENMP="${DARKNET_BUILD_WITH_OPENMP:-0}";
CUDNN_HALF="${DARKNET_BUILD_WITH_CUDNN_HALF:-0}";
AVX="${DARKNET_BUILD_WITH_AVX:-0}";

case "$GPU" in
    1|0);;
    *) echo "Interpreting DARKNET_BUILD_WITH_GPU=$GPU as 0"; GPU=0;;
esac

case "$CUDNN" in
    1|0);;
    *) echo "Interpreting DARKNET_BUILD_WITH_CUDNN=$CUDNN as 0"; CUDNN=0;;
esac

case "$CUDNN_HALF" in
    1|0);;
    *) echo "Interpreting DARKNET_BUILD_WITH_CUDNN_HALF=$CUDNN_HALF as 0"; CUDNN_HALF=0;;
esac

case "$OPENCV" in
    1|0);;
    *) echo "Interpreting DARKNET_BUILD_WITH_OPENCV=$OPENCV as 0"; OPENCV=0;;
esac

case "$OPENMP" in
    1|0);;
    *) echo "Interpreting DARKNET_BUILD_WITH_OPENMP=$OPENMP as 0"; OPENMP=0;;
esac

case "$AVX" in
    1|0);;
    *) echo "Interpreting DARKNET_BUILD_WITH_AVX=$AVX as 0"; AVX=0;;
esac

sed -i -e "s/AVX=[01]/AVX=${AVX}/g" ./Makefile
sed -i -e "s/GPU=[01]/GPU=${GPU}/g" ./Makefile
sed -i -e "s/CUDNN=[01]/CUDNN=${CUDNN}/g" ./Makefile
sed -i -e "s/OPENCV=[01]/OPENCV=${OPENCV}/g" ./Makefile
sed -i -e "s/OPENMP=[01]/OPENMP=${OPENMP}/g" ./Makefile
sed -i -e "s/CUDNN_HALF=[01]/CUDNN_HALF=${CUDNN_HALF}/g" ./Makefile
sed -i -e "s/LIBSO=[01]/LIBSO=1/g" ./Makefile
sed -i -e "s/-l:\$(LIBNAMESO)/-ldarknet/g" ./Makefile

DEFAULT_ARCH=" -gencode arch=compute_35,code=sm_35 \
-gencode arch=compute_50,code=[sm_50,compute_50] \
-gencode arch=compute_52,code=[sm_52,compute_52] \
-gencode arch=compute_61,code=[sm_61,compute_61]"

# Remove trailing gencode lines
sed -i -e "/^\s*-gencode/d" ./Makefile

if [ ! -z "${DARKNET_BUILD_WITH_ARCH:-""}" ]; then
    echo ""
    echo "Note: Passing custom ARCH for Darknet build"
    echo""

    # Update the ARCH to be what was specified by the option
    sed -i -e "s/^ARCH=.*$/ARCH=${DARKNET_BUILD_WITH_ARCH}/g" ./Makefile
else
    sed -i -e "s/^ARCH=.*$/ARCH=${DEFAULT_ARCH}/g" ./Makefile
fi

make

if [ $? -ne 0 ]; then
    echo "Could not compile darknet";
    exit 2;
fi

# dive out
cd ..

if [ $GPU = 1 ]; then
    export DARKNET_DEFINES="GPU"
    export DARKNET_FLAGS="-L/usr/local/cuda/lib64 -lcuda -lcudart -lcublas -lcurand"
fi

if [ $CUDNN = 1 ]; then
    export DARKNET_DEFINES="$DARKNET_DEFINES CUDNN"
    export DARKNET_FLAGS="$DARKNET_FLAGS -l cudnn"
fi
