use braavos_account::utils::snip12::{calculate_snip12_hash, hash_call};
use starknet::account::Call;
use poseidon::poseidon_hash_span;

const MOA_TX_TYPE_HASH: felt252 =
    selector!(
        "\"MOATransaction\"(\"Proposer Guid\":\"felt\",\"Nonce\":\"felt\",\"Calls\":\"Call*\")\"Call\"(\"To\":\"ContractAddress\",\"Selector\":\"selector\",\"Calldata\":\"felt*\")"
    );


fn calculate_moa_tx_hash(proposer_guid: felt252, nonce: felt252, calls: Span<Call>) -> felt252 {
    calculate_snip12_hash('MOA.tx_hash', 1, hash_moa_tx(proposer_guid, nonce, calls))
}

fn hash_moa_tx(proposer_guid: felt252, nonce: felt252, mut calls: Span<Call>) -> felt252 {
    let mut hashed_calls: Array<felt252> = array![];

    loop {
        match calls.pop_front() {
            Option::Some(call) => { hashed_calls.append(hash_call(call)); },
            Option::None(_) => { break; },
        };
    };
    poseidon_hash_span(
        array![MOA_TX_TYPE_HASH, proposer_guid, nonce, poseidon_hash_span(hashed_calls.span())]
            .span()
    )
}
