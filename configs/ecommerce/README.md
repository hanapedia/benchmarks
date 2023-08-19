# Services
advertisement
auth
cart-db
cart
category
content-db
cost-calculation
customer-db
customer-support
discount
inventory
localization
marketing-db
mobile
notification
order-db
order
payment-db
payment
product
profile
recommendation
return-order
review
scheduling
search
shipping-db
shipping
tax
tracking
user-db
user-preference
web
wishlist

# Event Driven
## Core Events
### OrderCreated
Publisher:
- order: in checkout
Subscribers:
- payment: replaces pay
- user-preference: replaces update
- notification: replaces ordercreated
Other notes:
- cost-calculation/calculate moved inside payment

### OrderCancelled
Publisher:
- order: in cancel
Subscribers:
- payment: replaces refund
- notification: replaces ordercancel

### OrderRescheduled
Publisher:
- order: in rescheduled
Subscribers:
- notification: replaces orderrescheduled

### SignUp
Publisher:
- auth: signup
Subscribers:
- profile: create
- user-preference: update
- localization: update
- notification: signup

### LogIn
Publisher:
- auth: login
Subscribers:
- notification: login

### LogOut
Publisher:
- auth: logout
Subscribers:
- notification: logout

### ProductSearched
Publisher:
- search: search
Subscribers:
- recommendation: update

### CartEdited
Publisher:
- cart: update
Subscribers:
- recommendation: update
- user-preference: update
- inventory: update

### WishlistEdited
Publisher:
- wishlist: update
Subscribers:
- recommendation: update
- user-preference: update

### ReturnRequested
Publisher:
- return-order: return
Subscribers:
- payment: pay[cost-calculation: refund]
- notification: return

### ReviewPosted
Publisher:
- review: post
Subscribers:
- recommendation: update
- user-preference: update
