# Little Shop Extensions

Two "extension" stories, "More Merchant Stats" and "Coupon Codes" were assigned to me for the final week solo project for Backend Module 2. I worked off an alternate code base written by the instructors. Below are the general goals, completion criteria and implementation guidelines for each extension. See my steps going forward beneath the projects guidelines.

## More Merchant Stats

#### General Goal

Build a Merchant leaderboard as part of the "/merchants" page containing additional statistics that all users can see.

#### Completion criteria

1. Add the following leaderboard items:
  - Top 10 Merchants who sold the most items this month
  - Top 10 Merchants who sold the most items last month
  - Top 10 Merchants who fulfilled non-cancelled orders this month
  - Top 10 Merchants who fulfilled non-cancelled orders last month

2. When logged in as a user, the following stats are also displayed on the "/merchants" page as well:
  - Also see top 5 merchants who have fulfilled items the fastest to my state
  - Also see top 5 merchants who have fulfilled items the fastest to my city

#### Implementation Guidelines

1. It may be tricky to build any one portion of these statistics in a single ActiveRecord call. You can use multiple calls in a method to build these statistics, but allow the database to do the calculations, not Ruby.

#### Mod 2 Learning Goals reflected:

- Advanced ActiveRecord
- Software Testing
- HTML/CSS layout and styling

---

## Coupon Codes

#### General Goals

Merchants can generate coupon codes within the system.

#### Completion Criteria

1. Merchants have a link on their dashboard to manage their coupons.
1. Merchants have full CRUD functionality over their coupons with exceptions mentioned below:
  - merchants cannot delete a coupon that has been used
  - merchants can have a maximum of 5 coupons in the system
  - merchants can enable/disable coupon codes
1. A coupon will have a name, and either percent-off or dollar-off value. The name must be unique in the whole database.
1. Users need a way to add a coupon code when checking out. Only one coupon may be used per order.
1. Coupons can be used by multiple users, but may only be used one time per user.
1. If a coupon's dollar value ($10 off) exceeds the total cost of everything in the cart, the cart price is $0, it should not display a negative value.
1. A coupon code from a merchant only applies to items sold by that merchant.

#### Implementation Guidelines

1. Users can enter different coupon codes until they finish checking out, then their choice is final.
1. The cart show page should calculate subtotals and the grand total as usual, but also show a "discounted total".
1. Order show pages should display which coupon was used.
1. If a user adds a coupon code, they can continue shopping. The coupon code is still remembered when returning to the cart page.

#### Mod 2 Learning Goals reflected:

- Database relationships and migrations
- ActiveRecord
- Software Testing
- HTML/CSS layout and styling

---

## Going Forward

The following is a list of items that I would like to revisit.

- Derive discounted totals with additional model methods. There is the newly added attribute 'discount' attribute that is not being utilized. Currently the discounted total is being calculated upon creation of an order in the OrdersController, line 38.

- Dry up test data. This project was my second exposure to Factory Bot. There are redundancies in my test data due to my unfamiliarity with the gem and not having enough time to tidy up before the project due date, especially related to my statistics. In particular, I would like to target user_spec.rb and merchants/index_spec.rb.

- Increase add coupon functionality. Currently it works only with percentages entered as a float. I would like to convert numbers to float and add functionality to allow for dollar amounts to be added.
