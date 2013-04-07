# Journey 2.9

* Remove the paywall and add the ability to support us by voluntary donation instead
* Switch from [ae_users](https://github.com/nbudin/ae_users) to [Sugar Pond Accounts](https://accounts.sugarpond.net) (using [devise](https://github.com/plataformatec/devise), [devise_cas_authenticatable](https://github.com/nbudin/devise_cas_authenticatable) and [cancan](https://github.com/ryanb/cancan))
* Gender is now a freeform text field by default (although survey creators can still make it any type of question they choose)
* Graphs: Add a checkbox to allow survey admins to omit responses with no answer from the graphed set (thanks Tim Lasko for the idea)