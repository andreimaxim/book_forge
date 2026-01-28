I want you to build a Salesforce clone targeted at the book publishing industry.

I want you to use the following stack:

* Ruby on Rails 8.x (latest version) with Postgresql, Erb partials and Hotwire-enhanced frontend, and Minitest
* Deployment will be done to Heroku and will use the Heroku Postgres database

The UI should be inspired by the 37signals design.

The application should have support for:

* managing authors
* managing publishers
* managing agents
* managing prospects
* managing books
* managing deals
* a global search

It should also have a dashboard with the general metrics and with an activity timeline.

Create a very detailed plan with detailed use cases for each component.

Example use case:

---
Use Case: User Registration
Actor: Visitor (unauthenticated user)

Preconditions:

- User is not logged in
- Email is not already registered

Main Flow:

1. Visitor navigates to registration page
2. Visitor enters email, password, and password confirmation
3. System validates input
4. System creates user account
5. System sends welcome email
6. System logs user in
7. System redirects to dashboard

Postconditions:

- User exists in database
- User is authenticated
- Welcome email is queued
Alternative Flows:
- 3a. Email already exists → show error, stay on form
- 3b. Password too short → show error, stay on form
- 3c. Passwords don't match → show error, stay on form

Error Conditions:
- Email service unavailable → create user anyway, retry email later  
---

Save the plan to PLAN.md
