'reach 0.1';
'use strict';

// -----------------------------------------------
// Name: Interface Template
// Description: NP Rapp simple
// Author: Nicholas Shellabarger
// Version: 0.0.2 - initial
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
export const Participants = () =>[
  Participant('Admin', {
    getParams: Fun([], Object({
      name: Bytes(32),
      token: Token,
      price: UInt
    })),
    signal: Fun([], Null)
  }),
]
export const Views = () => [
  View({
    admin: Address,
    price: UInt,
    token: Token,
    name: Bytes(32),
    count: UInt,
  })
]
export const Api = () => [
  API({
    incr: Fun([], Null),
    destroy: Fun([], Null)
  })
]
export const App = ([
  [Admin],
  [v],
  [a]
]) => {
  Admin.only(() => {
    const {
      name,
      token,
      price,
    } = declassify(interact.getParams())
  })
  Admin.publish(name, token, price)
  Admin.interact.signal()
  v.admin.set(Admin)
  v.name.set(name)
  v.token.set(token)
  v.price.set(price)
  v.count.set(0)
  const [keepGoing, as] =
  parallelReduce([true, 0])
  .define(() => {
    v.count.set(as)
  })
  .invariant(balance() >= 0)
  .while(keepGoing)
  .api(a.incr,
    () => assume(true),
    () => 0,
    (k) => {
      require(true);
      k(null);
      return [
        true, as+1
      ];
    })
    .api(a.destroy,
      () => assume(this == Admin),
      () => 0,
      (k) => {
        require(this == Admin);
        k(null);
        return [
          false, as
        ];
      })
     
  .timeout(false);
  transfer(balance()).to(Admin)
  transfer(balance(token), token).to(Admin)
  commit()
  exit()
}
// ----------------------------------------------
