#!/usr/bin/env bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    install_name_tool -change libdarknet.so "$(pwd)/darknet/libdarknet.so" build/Release/darknet.node
fi
