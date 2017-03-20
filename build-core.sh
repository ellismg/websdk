#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

SCRIPT_ROOT="$(dirname "${BASH_SOURCE[0]}")"
DOTNET_TOOL_ROOT="$SCRIPT_ROOT/obj/tools/dotnet"

curl -L https://raw.githubusercontent.com/dotnet/cli/rel/1.0.0/scripts/obtain/dotnet-install.sh | bash -s -- --version 1.0.0 --install-dir "$DOTNET_TOOL_ROOT"

export PATH=$DOTNET_TOOL_ROOT:$PATH

$SCRIPT_ROOT/tools/BuildCore.sh
