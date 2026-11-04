# Raysto 0.16: the names streams build against

Franchise groups, the AI accountant, delivery with drivers and a partner API, the supply manager, and AG Studio across the back office. Backend 0.16.0, console 0.18.x, app 0.16.0. Migration `20261104013844404` (16 new tables, nullable columns on four, nothing dropped).

The console proxy (`web/src/lib/connected/proxy-allowlist.ts`, `phase16Commands` / `phase16Queries`) may relay these names before the backend answers them; its drift test accepts a name only while it is listed on the two lines below and in a `phase16` set.

Commands: `group.create`, `group.attach`, `group.detach`, `group.member.invite`, `group.template.save`, `group.template.push`, `stock.transfer`, `bill.snap`, `bill.save`, `bill.approve`, `bill.pay`, `bill.markPaid`, `bill.void`, `request.create`, `request.send`, `request.remind`, `request.cancel`, `ledger.adjust`, `accountant.run`, `driver.save`, `driver.availability`, `delivery.offer`, `delivery.respond`, `delivery.proof`, `delivery.assign`, `delivery.transition`, `dispatch.suggest`, `partner.app.save`, `partner.app.rotate`, `supplier.order.save`, `supplier.order.send`, `supplier.order.receive`, `recipe.save`, `stock.count`, `stock.waste`, `stock.save`, `supplier.save`, `supply.receive`, `supplies.plan`, `expense.snap`, `studio.layout.save`, `media.upload`

Queries: `group.list`, `group.overview`, `group.compare`, `group.ledger`, `group.payables`, `group.templates`, `ledger.journal`, `ledger.pnl`, `ledger.cashflow`, `ledger.vat`, `bills`, `bill`, `requests`, `request`, `drivers`, `delivery.board`, `deliveries`, `delivery.tracking`, `partner.apps`, `partner.events`, `supplier.orders`, `supplier.order`, `stock`, `stock.forecast`, `suppliers`, `recipes`, `supply.deliveries`, `supplier.scorecards`, `studio.layout`, `team`

| Area | Backend files (owner) | Console | App |
|---|---|---|---|
| Groups | `group.dart`, `studio_layout.dart` (S4) | `group-section.tsx`, `studio/*` | `group_today.dart` |
| Accountant | `ledger.dart`, `accountant.dart`, `agent_accountant.dart`, `web/pay_link_route.dart` (S1) | `accountant-section.tsx` | `accountant.dart` |
| Delivery | `delivery.dart`, `partner.dart`, `agent_dispatch.dart`, `web/partner_routes.dart`, delivery block of `ordering.dart` (S2) | `dispatch-section.tsx` | `courier_home.dart`, `tracking_map.dart`, `osm_map.dart` |
| Supplies | `purchasing.dart`, `agent_supplies_plan.dart`, `agent_supplies.dart` (S3) | `supplies-section.tsx` | `supplies.dart` |

New roles and settings: venue role `accountant` (owner-invited; core set `_finance` = owner, manager, accountant). Autonomy gains `billsMaxMinor`, `billsPerDay`, `billsKnownPayeesOnly` (owner and identity check to change). Delivery settings `deliveryFeeMode`, `deliveryFeeBaseMinor`, `deliveryFeePerKmMinor`, `deliveryFeeMaxMinor`, `deliveryProof`, `driverPayPerDeliveryMinor`, `dispatchAuto`. Upload purposes `bill` (PDF up to 5 pages), `receipt`, `deliveryNote` (finance roles) and `deliveryProof` (couriers).
