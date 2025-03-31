import { describe, it, expect, beforeAll } from "vitest";

let chain;
let deployer;
let wallet1;
let wallet2;
let charityWallet = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"; //


beforeAll(async () => {
  chain = new Chain();
  deployer = chain.accounts.get("deployer")!;
  wallet1 = chain.accounts.get("wallet_1")!;
  wallet2 = chain.accounts.get("wallet_2")!;
});

describe("ECO Token Contract", () => {
  it("should allow admin to mint tokens", () => {
    let block = chain.mineBlock([
      Tx.contractCall("eco-token", "mint", [wallet1.address, "1000"], deployer.address),
    ]);

    let result = block.receipts[0].result;
    expect(result.expectOk()).toBe("1000");

    let balance = chain.callReadOnlyFn("eco-token", "get-balance", [wallet1.address], wallet1.address);
    expect(balance.result.expectUint()).toBe(1000);
  });

  it("should not allow non-admin to mint tokens", () => {
    let block = chain.mineBlock([
      Tx.contractCall("eco-token", "mint", [wallet1.address, "1000"], wallet2.address),
    ]);

    let result = block.receipts[0].result;
    expect(result.expectErr()).toBe('"Only admin can mint"');
  });

  it("should allow users to transfer tokens", () => {
    chain.mineBlock([
      Tx.contractCall("eco-token", "mint", [wallet1.address, "1000"], deployer.address),
    ]);

    let block = chain.mineBlock([
      Tx.contractCall("eco-token", "transfer", ["500", wallet2.address], wallet1.address),
    ]);

    let result = block.receipts[0].result;
    expect(result.expectOk()).toBe("500");
  });

  it("should allow users to donate tokens", () => {
    chain.mineBlock([
      Tx.contractCall("eco-token", "mint", [wallet1.address, "1000"], deployer.address),
    ]);

    let block = chain.mineBlock([
      Tx.contractCall("eco-token", "donate", ["500"], wallet1.address),
    ]);

    let result = block.receipts[0].result;
    expect(result.expectOk()).toBe("500");
  });

  it("should allow only admin to allocate funds", () => {
    chain.mineBlock([
      Tx.contractCall("eco-token", "mint", [charityWallet, "1000"], deployer.address),
    ]);

    let block = chain.mineBlock([
      Tx.contractCall("eco-token", "allocate-funds", [wallet1.address, "500"], wallet2.address),
    ]);

    let result = block.receipts[0].result;
    expect(result.expectErr()).toBe('"Only admin can allocate"');
  });

  it("should allow users to vote on proposals", () => {
    chain.mineBlock([
      Tx.contractCall("eco-token", "mint", [wallet1.address, "1000"], deployer.address),
    ]);

    let block = chain.mineBlock([
      Tx.contractCall("eco-token", "vote", ["0x50726F706F73616C31", "300"], wallet1.address),
    ]);

    let result = block.receipts[0].result;
    expect(result.expectOk()).toBe("300");
  });
});
