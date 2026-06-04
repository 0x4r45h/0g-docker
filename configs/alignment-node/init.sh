#!/bin/bash

register_operator() {
  0g-alignment-node registerOperator \
    --key "$ALIGNMENT_NODE_PRIVATE_KEY" \
    --token-id "$ALIGNMENT_NODE_TOKEN_ID" \
    --chain-id 16661 \
    --rpc "$ALIGNMENT_NODE_RPC" \
    --commission "$ALIGNMENT_NODE_OPERATOR_COMMISSION" \
    --contract 0x7BDc2aECC3CDaF0ce5a975adeA1C8d84Fd9Be3D9
}

approve_delegates() {
  0g-alignment-node approve --mainnet \
    --key "$ALIGNMENT_NODE_PRIVATE_KEY" \
    --chain-id 16661 \
    --rpc "$ALIGNMENT_NODE_RPC" \
    --contract 0x7BDc2aECC3CDaF0ce5a975adeA1C8d84Fd9Be3D9 \
    --destNode "$ALIGNMENT_NODE_OPERATOR_ADDRESS" \
    --tokenIds "$ALIGNMENT_NODE_DELEGATE_TOKEN_IDS"
}

usage() {
  echo "Usage: $0 [register_operator|approve_delegates]" >&2
}

main() {
  local cmd="${1:-}"
  case "$cmd" in
    register_operator)
      register_operator
      ;;
    approve_delegates)
      approve_delegates
      ;;
    ""|help|-h|--help)
      usage
      ;;
    *)
      echo "Unknown command: $cmd" >&2
      usage
      exit 1
      ;;
  esac
}

# If executed directly (not sourced), run main with all CLI args
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
