# BookForge - Book Publishing CRM Implementation Plan

A Salesforce clone for the book publishing industry built with Ruby on Rails 8.x, PostgreSQL, Hotwire, and 37signals-inspired design.

---

## Overview

### Domain Model

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Author    │────<│    Book     │>────│  Publisher  │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Agent    │────<│    Deal     │>────│  Activity   │
└─────────────┘     └─────────────┘     └─────────────┘
       │
       ▼
┌─────────────┐
│  Prospect   │
└─────────────┘
```

### Tech Stack
- Ruby on Rails 8.x
- PostgreSQL
- ERB templates with partials
- Hotwire (Turbo Drive, Turbo Frames, Turbo Streams)
- Stimulus.js for progressive enhancement
- Minitest for testing
- Heroku for deployment

---

## Phase 1: Foundation

### Step 1.1: Project Setup and Configuration

**Objective:** Initialize Rails 8 application with PostgreSQL, configure for Heroku deployment, and establish project conventions.

**Implementation Tasks:**
1. Generate new Rails 8 application with PostgreSQL
2. Configure database.yml for local development and Heroku
3. Set up Procfile for Heroku
4. Configure asset pipeline for 37signals-style CSS
5. Create base layout with navigation structure
6. Set up system test configuration with Capybara
7. Create ApplicationRecord with common concerns
8. Configure Turbo and Stimulus

**File Structure:**
```
app/
├── assets/
│   └── stylesheets/
│       ├── application.css
│       └── components/
│           ├── buttons.css
│           ├── forms.css
│           ├── cards.css
│           └── navigation.css
├── views/
│   └── layouts/
│       ├── application.html.erb
│       └── _navigation.html.erb
config/
├── database.yml
└── initializers/
    └── inflections.rb
Procfile
```

**Test Cases:**

```ruby
# test/application_system_test_case.rb - Base configuration

# test/system/navigation_test.rb
class NavigationTest < ApplicationSystemTestCase
  test "displays main navigation with all sections"
  test "highlights current section in navigation"
  test "navigation is responsive on mobile devices"
end

# test/controllers/health_controller_test.rb
class HealthControllerTest < ActionDispatch::IntegrationTest
  test "health check returns success status"
  test "health check includes database connection status"
end
```

---

### Step 1.2: Design System and UI Components

**Objective:** Create a 37signals-inspired design system with reusable components.

**Implementation Tasks:**
1. Define color palette and typography (inspired by Basecamp/HEY)
2. Create button component styles (primary, secondary, danger)
3. Create form input styles with validation states
4. Create card components for list items
5. Create table styles for data display
6. Create flash message styles
7. Create pagination component
8. Create empty state components
9. Build view helpers for common UI patterns

**File Structure:**
```
app/
├── assets/
│   └── stylesheets/
│       ├── base/
│       │   ├── reset.css
│       │   ├── typography.css
│       │   └── variables.css
│       └── components/
│           ├── buttons.css
│           ├── forms.css
│           ├── cards.css
│           ├── tables.css
│           ├── flash.css
│           ├── pagination.css
│           └── empty_states.css
├── helpers/
│   └── ui_helper.rb
└── views/
    └── shared/
        ├── _flash.html.erb
        ├── _pagination.html.erb
        └── _empty_state.html.erb
```

**Test Cases:**

```ruby
# test/helpers/ui_helper_test.rb
class UiHelperTest < ActionView::TestCase
  test "renders primary button with correct styling"
  test "renders secondary button with correct styling"
  test "renders danger button with confirmation"
  test "renders form field with label and error"
  test "renders card component with title and content"
  test "renders empty state with icon and message"
  test "renders badge with appropriate color for status"
end

# test/system/design_system_test.rb
class DesignSystemTest < ApplicationSystemTestCase
  test "flash messages appear and can be dismissed"
  test "form validation errors display inline"
  test "buttons show loading state when clicked"
end
```

---

## Phase 2: Core Entities

### Step 2.1: Authors Management

**Objective:** Full CRUD for authors with search, filtering, and contact management.

**Database Schema:**
```ruby
create_table :authors do |t|
  t.string :first_name, null: false
  t.string :last_name, null: false
  t.string :email
  t.string :phone
  t.text :bio
  t.string :website
  t.string :genre_focus
  t.string :status, default: 'active' # active, inactive, deceased
  t.date :date_of_birth
  t.text :notes
  t.timestamps
end

add_index :authors, :email, unique: true, where: "email IS NOT NULL"
add_index :authors, [:last_name, :first_name]
add_index :authors, :status
```

**Implementation Tasks:**
1. Generate Author model with validations
2. Create AuthorsController with CRUD actions
3. Build index view with search and filtering
4. Build show view with author details and related records tabs
5. Build form partial for new/edit
6. Add Turbo Frame for inline editing
7. Implement status management
8. Add avatar placeholder based on initials

**File Structure:**
```
app/
├── models/
│   └── author.rb
├── controllers/
│   └── authors_controller.rb
└── views/
    └── authors/
        ├── index.html.erb
        ├── show.html.erb
        ├── new.html.erb
        ├── edit.html.erb
        ├── _form.html.erb
        ├── _author.html.erb
        ├── _search_form.html.erb
        └── _filters.html.erb
```

**Test Cases:**

```ruby
# test/models/author_test.rb
class AuthorTest < ActiveSupport::TestCase
  test "requires first name"
  test "requires last name"
  test "validates email format when provided"
  test "validates email uniqueness when provided"
  test "validates website format when provided"
  test "validates status is a known value"
  test "returns full name combining first and last name"
  test "returns initials from first and last name"
  test "scopes active authors"
  test "scopes authors by genre focus"
  test "searches authors by name"
  test "searches authors by email"
  test "orders authors alphabetically by last name"
end

# test/controllers/authors_controller_test.rb
class AuthorsControllerTest < ActionDispatch::IntegrationTest
  test "lists all authors"
  test "filters authors by status"
  test "filters authors by genre focus"
  test "searches authors by name"
  test "shows author details"
  test "renders new author form"
  test "creates author with valid data"
  test "rejects author creation with invalid data"
  test "renders edit author form"
  test "updates author with valid data"
  test "rejects author update with invalid data"
  test "deletes author without associated records"
  test "prevents deletion of author with associated books"
end

# test/system/authors_test.rb
class AuthorsSystemTest < ApplicationSystemTestCase
  test "viewing the authors list"
  test "searching for an author by name"
  test "filtering authors by status"
  test "creating a new author"
  test "viewing author details"
  test "editing an author inline"
  test "changing author status"
  test "navigating between author tabs"
end
```

---

### Step 2.2: Publishers Management

**Objective:** Full CRUD for publishers with imprints support and contact management.

**Database Schema:**
```ruby
create_table :publishers do |t|
  t.string :name, null: false
  t.string :imprint
  t.string :address_line1
  t.string :address_line2
  t.string :city
  t.string :state
  t.string :postal_code
  t.string :country, default: 'USA'
  t.string :phone
  t.string :website
  t.string :contact_name
  t.string :contact_email
  t.string :contact_phone
  t.string :size # big_five, major, mid_size, small, indie
  t.text :notes
  t.string :status, default: 'active' # active, inactive
  t.timestamps
end

add_index :publishers, :name
add_index :publishers, :size
add_index :publishers, :status
```

**Implementation Tasks:**
1. Generate Publisher model with validations
2. Create PublishersController with CRUD actions
3. Build index view with filtering by size
4. Build show view with publisher details
5. Build form partial with address fields
6. Add support for imprints (sub-publishers)
7. Implement publisher size categorization

**File Structure:**
```
app/
├── models/
│   └── publisher.rb
├── controllers/
│   └── publishers_controller.rb
└── views/
    └── publishers/
        ├── index.html.erb
        ├── show.html.erb
        ├── new.html.erb
        ├── edit.html.erb
        ├── _form.html.erb
        ├── _publisher.html.erb
        └── _filters.html.erb
```

**Test Cases:**

```ruby
# test/models/publisher_test.rb
class PublisherTest < ActiveSupport::TestCase
  test "requires name"
  test "validates contact email format when provided"
  test "validates website format when provided"
  test "validates size is a known value"
  test "validates status is a known value"
  test "returns full address formatted"
  test "scopes active publishers"
  test "scopes publishers by size category"
  test "searches publishers by name"
  test "orders publishers alphabetically"
  test "identifies big five publishers"
  test "returns display name with imprint when present"
end

# test/controllers/publishers_controller_test.rb
class PublishersControllerTest < ActionDispatch::IntegrationTest
  test "lists all publishers"
  test "filters publishers by size"
  test "filters publishers by status"
  test "searches publishers by name"
  test "shows publisher details"
  test "creates publisher with valid data"
  test "updates publisher with valid data"
  test "deletes publisher without associated records"
  test "prevents deletion of publisher with associated deals"
end

# test/system/publishers_test.rb
class PublishersSystemTest < ApplicationSystemTestCase
  test "viewing the publishers list"
  test "filtering publishers by size"
  test "creating a new publisher"
  test "viewing publisher details with deals"
  test "editing publisher contact information"
end
```

---

### Step 2.3: Agents Management

**Objective:** Full CRUD for literary agents with agency support and client tracking.

**Database Schema:**
```ruby
create_table :agents do |t|
  t.string :first_name, null: false
  t.string :last_name, null: false
  t.string :email
  t.string :phone
  t.string :agency_name
  t.string :agency_website
  t.string :address_line1
  t.string :address_line2
  t.string :city
  t.string :state
  t.string :postal_code
  t.string :country, default: 'USA'
  t.decimal :commission_rate, precision: 5, scale: 2, default: 15.00
  t.text :genres_represented # stored as comma-separated or JSON
  t.text :notes
  t.string :status, default: 'active' # active, inactive, not_accepting
  t.timestamps
end

add_index :agents, [:last_name, :first_name]
add_index :agents, :agency_name
add_index :agents, :status
add_index :agents, :email, unique: true, where: "email IS NOT NULL"
```

**Implementation Tasks:**
1. Generate Agent model with validations
2. Create AgentsController with CRUD actions
3. Build index view with agency grouping option
4. Build show view with represented authors
5. Build form partial with commission rate
6. Implement genre preferences management
7. Add agency-based filtering

**File Structure:**
```
app/
├── models/
│   └── agent.rb
├── controllers/
│   └── agents_controller.rb
└── views/
    └── agents/
        ├── index.html.erb
        ├── show.html.erb
        ├── new.html.erb
        ├── edit.html.erb
        ├── _form.html.erb
        ├── _agent.html.erb
        └── _filters.html.erb
```

**Test Cases:**

```ruby
# test/models/agent_test.rb
class AgentTest < ActiveSupport::TestCase
  test "requires first name"
  test "requires last name"
  test "validates email format when provided"
  test "validates email uniqueness when provided"
  test "validates commission rate is between 0 and 100"
  test "validates status is a known value"
  test "returns full name"
  test "returns full name with agency"
  test "returns genres as array"
  test "sets genres from array"
  test "scopes active agents"
  test "scopes agents accepting new clients"
  test "scopes agents by agency"
  test "scopes agents by genre represented"
  test "searches agents by name"
  test "searches agents by agency name"
  test "calculates commission for amount"
end

# test/controllers/agents_controller_test.rb
class AgentsControllerTest < ActionDispatch::IntegrationTest
  test "lists all agents"
  test "groups agents by agency"
  test "filters agents by status"
  test "filters agents by genre"
  test "shows agent details"
  test "creates agent with valid data"
  test "updates agent with valid data"
  test "deletes agent without associated records"
end

# test/system/agents_test.rb
class AgentsSystemTest < ApplicationSystemTestCase
  test "viewing the agents list"
  test "viewing agents grouped by agency"
  test "filtering agents by genre represented"
  test "creating a new agent"
  test "viewing agent details with clients"
  test "editing agent commission rate"
end
```

---

### Step 2.4: Prospects Management

**Objective:** Full CRUD for prospects (potential authors or leads) with pipeline stages.

**Database Schema:**
```ruby
create_table :prospects do |t|
  t.string :first_name, null: false
  t.string :last_name, null: false
  t.string :email
  t.string :phone
  t.string :source # query_letter, referral, conference, social_media, website, other
  t.string :stage, default: 'new' # new, contacted, evaluating, negotiating, converted, declined
  t.string :genre_interest
  t.string :project_title
  t.text :project_description
  t.integer :estimated_word_count
  t.text :notes
  t.references :agent, foreign_key: true # assigned agent
  t.date :last_contact_date
  t.date :follow_up_date
  t.timestamps
end

add_index :prospects, :stage
add_index :prospects, :source
add_index :prospects, :follow_up_date
add_index :prospects, [:last_name, :first_name]
```

**Implementation Tasks:**
1. Generate Prospect model with validations
2. Create ProspectsController with CRUD actions
3. Build index view with pipeline/kanban view option
4. Build show view with activity history
5. Build form partial with stage management
6. Implement stage transitions with validation
7. Add follow-up reminders view
8. Create conversion to author functionality

**File Structure:**
```
app/
├── models/
│   └── prospect.rb
├── controllers/
│   └── prospects_controller.rb
└── views/
    └── prospects/
        ├── index.html.erb
        ├── show.html.erb
        ├── new.html.erb
        ├── edit.html.erb
        ├── _form.html.erb
        ├── _prospect.html.erb
        ├── _pipeline.html.erb
        ├── _filters.html.erb
        └── _convert_form.html.erb
```

**Test Cases:**

```ruby
# test/models/prospect_test.rb
class ProspectTest < ActiveSupport::TestCase
  test "requires first name"
  test "requires last name"
  test "validates email format when provided"
  test "validates source is a known value"
  test "validates stage is a known value"
  test "validates estimated word count is positive"
  test "returns full name"
  test "scopes prospects by stage"
  test "scopes prospects by source"
  test "scopes prospects needing follow up today"
  test "scopes prospects needing follow up this week"
  test "scopes prospects overdue for follow up"
  test "scopes unassigned prospects"
  test "searches prospects by name"
  test "searches prospects by project title"
  test "transitions to next stage"
  test "prevents invalid stage transitions"
  test "converts to author record"
  test "marks as declined with reason"
  test "calculates days in current stage"
end

# test/controllers/prospects_controller_test.rb
class ProspectsControllerTest < ActionDispatch::IntegrationTest
  test "lists all prospects"
  test "displays prospects in pipeline view"
  test "filters prospects by stage"
  test "filters prospects by source"
  test "filters prospects by assigned agent"
  test "shows prospects needing follow up"
  test "shows prospect details"
  test "creates prospect with valid data"
  test "updates prospect stage"
  test "assigns agent to prospect"
  test "converts prospect to author"
  test "marks prospect as declined"
end

# test/system/prospects_test.rb
class ProspectsSystemTest < ApplicationSystemTestCase
  test "viewing the prospects list"
  test "viewing prospects in pipeline view"
  test "moving prospect between stages"
  test "creating a new prospect"
  test "viewing prospect details"
  test "assigning an agent to prospect"
  test "setting follow up date"
  test "converting prospect to author"
end
```

---

### Step 2.5: Books Management

**Objective:** Full CRUD for books with status tracking and manuscript details.

**Database Schema:**
```ruby
create_table :books do |t|
  t.string :title, null: false
  t.string :subtitle
  t.references :author, null: false, foreign_key: true
  t.string :genre, null: false
  t.string :subgenre
  t.integer :word_count
  t.text :synopsis
  t.text :description
  t.string :status, default: 'manuscript' # manuscript, submitted, under_review, accepted, in_production, published, out_of_print
  t.string :isbn
  t.date :publication_date
  t.decimal :list_price, precision: 8, scale: 2
  t.string :format # hardcover, paperback, ebook, audiobook
  t.integer :page_count
  t.string :cover_image_url
  t.text :notes
  t.timestamps
end

add_index :books, :title
add_index :books, :genre
add_index :books, :status
add_index :books, :isbn, unique: true, where: "isbn IS NOT NULL"
add_index :books, :publication_date
```

**Implementation Tasks:**
1. Generate Book model with validations
2. Create BooksController with CRUD actions
3. Build index view with grid and list views
4. Build show view with deals and timeline
5. Build form partial with genre selection
6. Implement status workflow
7. Add ISBN validation
8. Create publication tracking

**File Structure:**
```
app/
├── models/
│   └── book.rb
├── controllers/
│   └── books_controller.rb
└── views/
    └── books/
        ├── index.html.erb
        ├── show.html.erb
        ├── new.html.erb
        ├── edit.html.erb
        ├── _form.html.erb
        ├── _book.html.erb
        ├── _book_card.html.erb
        ├── _filters.html.erb
        └── _status_timeline.html.erb
```

**Test Cases:**

```ruby
# test/models/book_test.rb
class BookTest < ActiveSupport::TestCase
  test "requires title"
  test "requires author"
  test "requires genre"
  test "validates word count is positive"
  test "validates ISBN format when provided"
  test "validates ISBN uniqueness when provided"
  test "validates status is a known value"
  test "validates list price is positive when provided"
  test "validates page count is positive when provided"
  test "validates publication date is not in future for published books"
  test "scopes books by status"
  test "scopes books by genre"
  test "scopes books by author"
  test "scopes published books"
  test "scopes manuscripts awaiting deals"
  test "searches books by title"
  test "searches books by author name"
  test "searches books by ISBN"
  test "determines if book is published"
  test "determines if book has active deals"
  test "calculates time since submission"
  test "returns formatted word count"
end

# test/controllers/books_controller_test.rb
class BooksControllerTest < ActionDispatch::IntegrationTest
  test "lists all books"
  test "displays books in grid view"
  test "displays books in list view"
  test "filters books by status"
  test "filters books by genre"
  test "filters books by author"
  test "shows book details"
  test "creates book with valid data"
  test "creates book and associates with author"
  test "updates book status"
  test "updates book with publication details"
  test "deletes book without deals"
  test "prevents deletion of book with active deals"
end

# test/system/books_test.rb
class BooksSystemTest < ApplicationSystemTestCase
  test "viewing the books list"
  test "switching between grid and list views"
  test "filtering books by genre"
  test "creating a new book for an author"
  test "viewing book details with status timeline"
  test "updating book status"
  test "adding publication details to a book"
end
```

---

### Step 2.6: Deals Management

**Objective:** Full CRUD for publishing deals with financial tracking.

**Database Schema:**
```ruby
create_table :deals do |t|
  t.references :book, null: false, foreign_key: true
  t.references :publisher, null: false, foreign_key: true
  t.references :agent, foreign_key: true
  t.string :deal_type, null: false # world_rights, north_american, translation, audio, film_tv
  t.decimal :advance_amount, precision: 12, scale: 2
  t.string :advance_currency, default: 'USD'
  t.decimal :royalty_rate_hardcover, precision: 5, scale: 2
  t.decimal :royalty_rate_paperback, precision: 5, scale: 2
  t.decimal :royalty_rate_ebook, precision: 5, scale: 2
  t.string :status, default: 'negotiating' # negotiating, pending_contract, signed, active, completed, terminated
  t.date :offer_date
  t.date :contract_date
  t.date :delivery_date
  t.date :publication_date
  t.integer :option_books # number of books in option
  t.text :terms_summary
  t.text :notes
  t.timestamps
end

add_index :deals, :status
add_index :deals, :deal_type
add_index :deals, :offer_date
add_index :deals, :contract_date
```

**Implementation Tasks:**
1. Generate Deal model with validations
2. Create DealsController with CRUD actions
3. Build index view with pipeline view
4. Build show view with financial summary
5. Build form partial with publisher/agent selection
6. Implement deal status workflow
7. Add financial calculations (agent commission, etc.)
8. Create deal comparison view

**File Structure:**
```
app/
├── models/
│   └── deal.rb
├── controllers/
│   └── deals_controller.rb
└── views/
    └── deals/
        ├── index.html.erb
        ├── show.html.erb
        ├── new.html.erb
        ├── edit.html.erb
        ├── _form.html.erb
        ├── _deal.html.erb
        ├── _pipeline.html.erb
        ├── _financial_summary.html.erb
        └── _filters.html.erb
```

**Test Cases:**

```ruby
# test/models/deal_test.rb
class DealTest < ActiveSupport::TestCase
  test "requires book"
  test "requires publisher"
  test "requires deal type"
  test "validates deal type is a known value"
  test "validates status is a known value"
  test "validates advance amount is not negative"
  test "validates royalty rates are between 0 and 100"
  test "validates contract date is after offer date"
  test "validates delivery date is after contract date"
  test "scopes deals by status"
  test "scopes deals by deal type"
  test "scopes deals by publisher"
  test "scopes deals by agent"
  test "scopes active deals"
  test "scopes deals this year"
  test "scopes deals this quarter"
  test "calculates agent commission"
  test "calculates author net advance"
  test "calculates total deal value"
  test "returns formatted advance"
  test "determines if deal is signed"
  test "determines days to close"
  test "searches deals by book title"
  test "searches deals by author name"
end

# test/controllers/deals_controller_test.rb
class DealsControllerTest < ActionDispatch::IntegrationTest
  test "lists all deals"
  test "displays deals in pipeline view"
  test "filters deals by status"
  test "filters deals by deal type"
  test "filters deals by publisher"
  test "filters deals by date range"
  test "shows deal details"
  test "creates deal with valid data"
  test "updates deal status"
  test "updates deal financial terms"
  test "associates deal with agent"
  test "prevents creation of duplicate deals for same book and publisher"
end

# test/system/deals_test.rb
class DealsSystemTest < ApplicationSystemTestCase
  test "viewing the deals list"
  test "viewing deals in pipeline view"
  test "filtering deals by status"
  test "creating a new deal"
  test "viewing deal financial summary"
  test "updating deal terms"
  test "moving deal through status workflow"
end
```

---

## Phase 3: Relationships and Associations

### Step 3.1: Author-Agent Representations

**Objective:** Manage the many-to-many relationship between authors and agents.

**Database Schema:**
```ruby
create_table :representations do |t|
  t.references :author, null: false, foreign_key: true
  t.references :agent, null: false, foreign_key: true
  t.string :status, default: 'active' # active, ended
  t.date :start_date
  t.date :end_date
  t.boolean :primary, default: false
  t.text :notes
  t.timestamps
end

add_index :representations, [:author_id, :agent_id], unique: true
add_index :representations, :status
```

**Implementation Tasks:**
1. Generate Representation model
2. Add has_many :through associations to Author and Agent
3. Create nested management in Author and Agent show pages
4. Build Turbo Frame for adding/removing representations
5. Implement primary agent designation
6. Add representation history tracking

**File Structure:**
```
app/
├── models/
│   └── representation.rb
├── controllers/
│   └── representations_controller.rb
└── views/
    └── representations/
        ├── _form.html.erb
        ├── _representation.html.erb
        └── _list.html.erb
```

**Test Cases:**

```ruby
# test/models/representation_test.rb
class RepresentationTest < ActiveSupport::TestCase
  test "requires author"
  test "requires agent"
  test "validates uniqueness of author and agent combination"
  test "validates status is a known value"
  test "validates end date is after start date"
  test "scopes active representations"
  test "scopes ended representations"
  test "ensures only one primary agent per author"
  test "automatically sets start date to today if not provided"
  test "ends representation and sets end date"
  test "determines if representation is current"
  test "calculates representation duration"
end

# test/controllers/representations_controller_test.rb
class RepresentationsControllerTest < ActionDispatch::IntegrationTest
  test "creates representation between author and agent"
  test "prevents duplicate representation"
  test "updates representation status"
  test "sets agent as primary for author"
  test "ends representation"
  test "responds with turbo stream for create"
  test "responds with turbo stream for destroy"
end

# test/system/representations_test.rb
class RepresentationsSystemTest < ApplicationSystemTestCase
  test "adding agent to author from author page"
  test "adding author to agent from agent page"
  test "setting primary agent for author"
  test "ending a representation"
  test "viewing representation history"
end
```

---

### Step 3.2: Cross-Entity Navigation and Related Records

**Objective:** Enable seamless navigation between related records across all entities.

**Implementation Tasks:**
1. Add related records tabs to Author show page (books, deals, agents)
2. Add related records tabs to Publisher show page (books, deals)
3. Add related records tabs to Agent show page (authors, deals)
4. Add related records tabs to Book show page (deals)
5. Implement Turbo Frames for tab content loading
6. Add quick-add buttons for related records
7. Create summary counts in entity cards

**File Structure:**
```
app/
└── views/
    ├── authors/
    │   ├── _books_tab.html.erb
    │   ├── _deals_tab.html.erb
    │   └── _agents_tab.html.erb
    ├── publishers/
    │   ├── _books_tab.html.erb
    │   └── _deals_tab.html.erb
    ├── agents/
    │   ├── _authors_tab.html.erb
    │   └── _deals_tab.html.erb
    └── books/
        └── _deals_tab.html.erb
```

**Test Cases:**

```ruby
# test/system/cross_navigation_test.rb
class CrossNavigationSystemTest < ApplicationSystemTestCase
  test "viewing author's books from author page"
  test "viewing author's deals from author page"
  test "viewing author's agents from author page"
  test "navigating from author's book to book details"
  test "viewing publisher's books from publisher page"
  test "viewing publisher's deals from publisher page"
  test "viewing agent's authors from agent page"
  test "viewing agent's deals from agent page"
  test "navigating from deal to related book"
  test "navigating from deal to related publisher"
  test "navigating from book to author"
  test "quick adding a book from author page"
  test "quick adding a deal from book page"
end

# test/controllers/related_records_test.rb
class RelatedRecordsTest < ActionDispatch::IntegrationTest
  test "loads author books tab via turbo frame"
  test "loads author deals tab via turbo frame"
  test "loads publisher deals tab via turbo frame"
  test "loads agent authors tab via turbo frame"
end
```

---

## Phase 4: Activity Tracking

### Step 4.1: Activity System

**Objective:** Track all changes and events across the system for audit and timeline display.

**Database Schema:**
```ruby
create_table :activities do |t|
  t.string :trackable_type, null: false
  t.bigint :trackable_id, null: false
  t.string :action, null: false # created, updated, status_changed, note_added, etc.
  t.string :field_changed
  t.text :old_value
  t.text :new_value
  t.text :description
  t.jsonb :metadata, default: {}
  t.timestamps
end

add_index :activities, [:trackable_type, :trackable_id]
add_index :activities, :action
add_index :activities, :created_at
```

**Implementation Tasks:**
1. Generate Activity model
2. Create Trackable concern for models
3. Implement automatic activity logging via callbacks
4. Create manual activity logging for notes/comments
5. Build activity timeline partial
6. Add activity feeds to entity show pages
7. Implement activity filtering by type

**File Structure:**
```
app/
├── models/
│   ├── activity.rb
│   └── concerns/
│       └── trackable.rb
├── controllers/
│   └── activities_controller.rb
└── views/
    └── activities/
        ├── _activity.html.erb
        ├── _timeline.html.erb
        └── _filters.html.erb
```

**Test Cases:**

```ruby
# test/models/activity_test.rb
class ActivityTest < ActiveSupport::TestCase
  test "requires trackable"
  test "requires action"
  test "validates action is a known value"
  test "scopes activities by trackable"
  test "scopes activities by action type"
  test "scopes activities in date range"
  test "scopes recent activities"
  test "returns human readable description"
  test "returns formatted timestamp"
  test "returns changed field display name"
  test "stores metadata as JSON"
end

# test/models/concerns/trackable_test.rb
class TrackableTest < ActiveSupport::TestCase
  test "logs activity on record creation"
  test "logs activity on record update"
  test "logs activity on status change"
  test "logs activity on record deletion"
  test "captures old and new values for changes"
  test "does not log activity for unchanged saves"
  test "includes changed fields in activity"
end

# test/controllers/activities_controller_test.rb
class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  test "lists activities for a record"
  test "filters activities by action type"
  test "filters activities by date range"
  test "paginates activities"
end

# test/system/activities_test.rb
class ActivitiesSystemTest < ApplicationSystemTestCase
  test "viewing activity timeline on author page"
  test "viewing activity timeline on deal page"
  test "filtering activities by type"
  test "loading more activities"
end
```

---

### Step 4.2: Notes and Comments

**Objective:** Add note-taking capability to all entities.

**Database Schema:**
```ruby
create_table :notes do |t|
  t.string :notable_type, null: false
  t.bigint :notable_id, null: false
  t.text :content, null: false
  t.boolean :pinned, default: false
  t.timestamps
end

add_index :notes, [:notable_type, :notable_id]
add_index :notes, :pinned
add_index :notes, :created_at
```

**Implementation Tasks:**
1. Generate Note model with polymorphic association
2. Create Notable concern for models
3. Create NotesController with CRUD
4. Build inline note form with Turbo Streams
5. Add notes section to all entity show pages
6. Implement note pinning
7. Add Markdown support for notes

**File Structure:**
```
app/
├── models/
│   ├── note.rb
│   └── concerns/
│       └── notable.rb
├── controllers/
│   └── notes_controller.rb
└── views/
    └── notes/
        ├── _form.html.erb
        ├── _note.html.erb
        └── _list.html.erb
```

**Test Cases:**

```ruby
# test/models/note_test.rb
class NoteTest < ActiveSupport::TestCase
  test "requires notable"
  test "requires content"
  test "validates content minimum length"
  test "belongs to notable polymorphically"
  test "scopes pinned notes"
  test "scopes notes by date"
  test "orders by pinned first then by date"
  test "renders markdown content as HTML"
  test "sanitizes HTML in rendered content"
  test "returns preview of content"
end

# test/controllers/notes_controller_test.rb
class NotesControllerTest < ActionDispatch::IntegrationTest
  test "creates note for author"
  test "creates note for book"
  test "creates note for deal"
  test "updates note content"
  test "pins note"
  test "unpins note"
  test "deletes note"
  test "responds with turbo stream on create"
  test "responds with turbo stream on delete"
end

# test/system/notes_test.rb
class NotesSystemTest < ApplicationSystemTestCase
  test "adding a note to an author"
  test "adding a note to a deal"
  test "editing an existing note"
  test "deleting a note"
  test "pinning a note"
  test "viewing markdown formatted note"
end
```

---

## Phase 5: Dashboard and Reporting

### Step 5.1: Dashboard with Metrics

**Objective:** Create a comprehensive dashboard with key business metrics.

**Implementation Tasks:**
1. Create DashboardController
2. Build dashboard layout with metric cards
3. Implement key metrics calculations:
   - Total active authors
   - Total active deals
   - Deals this month/quarter/year
   - Total advance value
   - Average deal size
   - Conversion rate (prospects to authors)
   - Books in pipeline by status
4. Add metric comparison to previous period
5. Create quick action buttons
6. Add recent items section

**File Structure:**
```
app/
├── models/
│   └── dashboard/
│       ├── metrics.rb
│       └── stats.rb
├── controllers/
│   └── dashboard_controller.rb
└── views/
    └── dashboard/
        ├── index.html.erb
        ├── _metric_card.html.erb
        ├── _deals_summary.html.erb
        ├── _pipeline_summary.html.erb
        ├── _quick_actions.html.erb
        └── _recent_items.html.erb
```

**Test Cases:**

```ruby
# test/models/dashboard/metrics_test.rb
class Dashboard::MetricsTest < ActiveSupport::TestCase
  test "calculates total active authors"
  test "calculates total active deals"
  test "calculates deals count for current month"
  test "calculates deals count for current quarter"
  test "calculates deals count for current year"
  test "calculates total advance value for period"
  test "calculates average deal size for period"
  test "calculates prospect conversion rate"
  test "calculates metric change from previous period"
  test "counts books by status"
  test "counts deals by status"
  test "returns top publishers by deal count"
  test "returns top agents by deal count"
end

# test/controllers/dashboard_controller_test.rb
class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "displays dashboard with metrics"
  test "displays dashboard with empty state when no data"
  test "shows correct metrics for current period"
  test "shows comparison to previous period"
  test "displays recent items"
  test "caches expensive metric calculations"
end

# test/system/dashboard_test.rb
class DashboardSystemTest < ApplicationSystemTestCase
  test "viewing dashboard overview"
  test "viewing deal metrics"
  test "viewing pipeline summary"
  test "navigating from dashboard to entity list"
  test "using quick action buttons"
  test "viewing recent items"
end
```

---

### Step 5.2: Activity Timeline on Dashboard

**Objective:** Display a real-time activity feed on the dashboard.

**Implementation Tasks:**
1. Add activity timeline section to dashboard
2. Implement grouped activity display (by day)
3. Add filtering by entity type
4. Implement real-time updates with Turbo Streams
5. Add "load more" pagination
6. Create activity summary for each entity type

**File Structure:**
```
app/
├── controllers/
│   └── dashboard/
│       └── activities_controller.rb
└── views/
    └── dashboard/
        ├── _activity_timeline.html.erb
        ├── _activity_day.html.erb
        └── _activity_filters.html.erb
```

**Test Cases:**

```ruby
# test/controllers/dashboard/activities_controller_test.rb
class Dashboard::ActivitiesControllerTest < ActionDispatch::IntegrationTest
  test "lists recent activities"
  test "filters activities by entity type"
  test "paginates activities"
  test "groups activities by day"
  test "responds with turbo stream for load more"
end

# test/system/dashboard_activities_test.rb
class DashboardActivitiesSystemTest < ApplicationSystemTestCase
  test "viewing activity timeline on dashboard"
  test "filtering activities by entity type"
  test "loading more activities"
  test "navigating from activity to related record"
  test "activity updates in real time"
end
```

---

## Phase 6: Search

### Step 6.1: Global Search

**Objective:** Implement a comprehensive search across all entities.

**Implementation Tasks:**
1. Create Search model/service for unified search
2. Create SearchController
3. Build search bar component in navigation
4. Implement search results page with grouped results
5. Add search suggestions/autocomplete
6. Implement keyboard navigation (Cmd+K)
7. Add search filters by entity type
8. Create search result highlighting

**File Structure:**
```
app/
├── models/
│   └── search.rb
├── controllers/
│   └── search_controller.rb
├── javascript/
│   └── controllers/
│       ├── search_controller.js
│       └── keyboard_shortcuts_controller.js
└── views/
    └── search/
        ├── index.html.erb
        ├── _results.html.erb
        ├── _result_group.html.erb
        ├── _result_item.html.erb
        └── _search_bar.html.erb
```

**Test Cases:**

```ruby
# test/models/search_test.rb
class SearchTest < ActiveSupport::TestCase
  test "searches authors by name"
  test "searches authors by email"
  test "searches publishers by name"
  test "searches agents by name"
  test "searches agents by agency"
  test "searches prospects by name"
  test "searches prospects by project title"
  test "searches books by title"
  test "searches books by ISBN"
  test "searches deals by book title"
  test "returns results grouped by entity type"
  test "returns results with relevance score"
  test "limits total results"
  test "highlights matching terms in results"
  test "handles special characters in query"
  test "handles empty query"
  test "filters search by entity type"
end

# test/controllers/search_controller_test.rb
class SearchControllerTest < ActionDispatch::IntegrationTest
  test "returns search results page"
  test "returns search results grouped by type"
  test "filters search results by entity type"
  test "returns empty state for no results"
  test "responds with turbo stream for autocomplete"
  test "handles empty search query"
end

# test/system/search_test.rb
class SearchSystemTest < ApplicationSystemTestCase
  test "searching from navigation bar"
  test "viewing grouped search results"
  test "filtering search results by type"
  test "navigating to result from search"
  test "using keyboard shortcut to open search"
  test "using keyboard to navigate results"
  test "viewing search suggestions while typing"
  test "clearing search and starting new search"
end
```

---

## Phase 7: Hotwire Enhancements

### Step 7.1: Turbo Frames and Streams

**Objective:** Enhance user experience with Turbo Frames and Streams.

**Implementation Tasks:**
1. Wrap entity lists in Turbo Frames for filtering
2. Implement inline editing with Turbo Frames
3. Add Turbo Stream responses for CRUD operations
4. Implement modal dialogs with Turbo Frames
5. Add flash messages via Turbo Streams
6. Implement infinite scroll for lists
7. Add optimistic UI updates where appropriate

**File Structure:**
```
app/
├── views/
│   └── shared/
│       ├── _modal.html.erb
│       └── _flash_stream.turbo_stream.erb
└── javascript/
    └── controllers/
        ├── modal_controller.js
        └── infinite_scroll_controller.js
```

**Test Cases:**

```ruby
# test/system/turbo_frames_test.rb
class TurboFramesSystemTest < ApplicationSystemTestCase
  test "filtering list updates only the list frame"
  test "inline edit opens form in place"
  test "inline edit submit updates the item"
  test "inline edit cancel restores original content"
  test "modal opens without page navigation"
  test "modal form submission closes modal"
  test "modal can be closed with escape key"
end

# test/system/turbo_streams_test.rb
class TurboStreamsSystemTest < ApplicationSystemTestCase
  test "creating record appends to list"
  test "updating record replaces in list"
  test "deleting record removes from list"
  test "flash message appears and auto-dismisses"
  test "form errors display without page reload"
end

# test/controllers/turbo_responses_test.rb
class TurboResponsesTest < ActionDispatch::IntegrationTest
  test "create responds with turbo stream when requested"
  test "update responds with turbo stream when requested"
  test "destroy responds with turbo stream when requested"
  test "create falls back to redirect for non-turbo requests"
end
```

---

### Step 7.2: Stimulus Controllers

**Objective:** Add progressive enhancement with Stimulus controllers.

**Implementation Tasks:**
1. Create form validation controller
2. Create auto-save controller for forms
3. Create dropdown controller for menus
4. Create clipboard controller for copy actions
5. Create character count controller
6. Create filter controller for list pages
7. Create sortable controller for drag-and-drop
8. Create toast/notification controller

**File Structure:**
```
app/
└── javascript/
    └── controllers/
        ├── form_validation_controller.js
        ├── auto_save_controller.js
        ├── dropdown_controller.js
        ├── clipboard_controller.js
        ├── character_count_controller.js
        ├── filter_controller.js
        ├── sortable_controller.js
        └── toast_controller.js
```

**Test Cases:**

```ruby
# test/system/stimulus_controllers_test.rb
class StimulusControllersSystemTest < ApplicationSystemTestCase
  test "form shows validation errors before submit"
  test "form auto-saves draft after typing stops"
  test "dropdown opens on click"
  test "dropdown closes when clicking outside"
  test "dropdown closes on escape key"
  test "copy button copies text to clipboard"
  test "character count updates while typing"
  test "character count shows warning near limit"
  test "filter form submits automatically on change"
  test "list items can be reordered by dragging"
  test "toast notification appears and auto-dismisses"
  test "toast can be dismissed manually"
end
```

---

## Phase 8: Polish and Deployment

### Step 8.1: Error Handling and Edge Cases

**Objective:** Implement comprehensive error handling and edge case management.

**Implementation Tasks:**
1. Create custom error pages (404, 422, 500)
2. Implement form error handling
3. Add not found handling for all controllers
4. Implement stale record handling
5. Add request timeout handling
6. Create error logging service
7. Implement graceful degradation for JavaScript failures

**File Structure:**
```
app/
├── controllers/
│   └── concerns/
│       └── error_handling.rb
└── views/
    └── errors/
        ├── not_found.html.erb
        ├── unprocessable.html.erb
        └── internal_error.html.erb
```

**Test Cases:**

```ruby
# test/controllers/error_handling_test.rb
class ErrorHandlingTest < ActionDispatch::IntegrationTest
  test "displays 404 page for missing record"
  test "displays 404 page for missing route"
  test "displays 422 page for invalid form submission"
  test "displays 500 page for server error"
  test "logs errors appropriately"
  test "handles stale record gracefully"
end

# test/system/error_handling_test.rb
class ErrorHandlingSystemTest < ApplicationSystemTestCase
  test "shows error page for missing record"
  test "shows validation errors inline on form"
  test "recovers gracefully when JavaScript fails"
  test "can navigate back from error page"
end
```

---

### Step 8.2: Performance Optimization

**Objective:** Optimize application performance.

**Implementation Tasks:**
1. Add database indexes review
2. Implement eager loading for N+1 queries
3. Add pagination to all list views
4. Implement caching for expensive queries
5. Add database query logging in development
6. Optimize asset delivery
7. Implement counter caches where appropriate

**Test Cases:**

```ruby
# test/performance/query_performance_test.rb
class QueryPerformanceTest < ActiveSupport::TestCase
  test "authors index loads with constant queries regardless of record count"
  test "publishers index loads with constant queries regardless of record count"
  test "books index loads with constant queries regardless of record count"
  test "deals index loads with constant queries regardless of record count"
  test "dashboard loads with acceptable query count"
  test "search executes in acceptable time"
end

# test/models/counter_cache_test.rb
class CounterCacheTest < ActiveSupport::TestCase
  test "author books count is cached"
  test "author deals count is cached"
  test "publisher deals count is cached"
  test "agent representations count is cached"
end
```

---

### Step 8.3: Heroku Deployment Configuration

**Objective:** Configure application for Heroku deployment.

**Implementation Tasks:**
1. Create Procfile with web and worker processes
2. Configure production database settings
3. Set up environment variables documentation
4. Configure asset compilation for production
5. Set up production logging
6. Create release tasks for migrations
7. Configure health check endpoint
8. Document deployment process

**File Structure:**
```
Procfile
config/
├── database.yml
├── puma.rb
└── environments/
    └── production.rb
bin/
└── release
docs/
└── DEPLOYMENT.md
```

**Test Cases:**

```ruby
# test/integration/production_config_test.rb
class ProductionConfigTest < ActionDispatch::IntegrationTest
  test "health check endpoint returns success"
  test "static assets are served correctly"
  test "database connection is established"
end
```

---

## Summary

### Implementation Order

1. **Phase 1: Foundation** (Steps 1.1-1.2)
   - Project setup, configuration, design system

2. **Phase 2: Core Entities** (Steps 2.1-2.6)
   - Authors, Publishers, Agents, Prospects, Books, Deals

3. **Phase 3: Relationships** (Steps 3.1-3.2)
   - Author-Agent representations, Cross-entity navigation

4. **Phase 4: Activity Tracking** (Steps 4.1-4.2)
   - Activity system, Notes and comments

5. **Phase 5: Dashboard** (Steps 5.1-5.2)
   - Metrics dashboard, Activity timeline

6. **Phase 6: Search** (Step 6.1)
   - Global search functionality

7. **Phase 7: Hotwire** (Steps 7.1-7.2)
   - Turbo Frames/Streams, Stimulus controllers

8. **Phase 8: Polish** (Steps 8.1-8.3)
   - Error handling, Performance, Deployment

### Estimated Token Budget per Step

| Step | Description | Complexity |
|------|-------------|------------|
| 1.1 | Project Setup | Medium (~25k tokens) |
| 1.2 | Design System | Medium (~30k tokens) |
| 2.1 | Authors | High (~40k tokens) |
| 2.2 | Publishers | Medium (~35k tokens) |
| 2.3 | Agents | Medium (~35k tokens) |
| 2.4 | Prospects | High (~40k tokens) |
| 2.5 | Books | High (~40k tokens) |
| 2.6 | Deals | High (~45k tokens) |
| 3.1 | Representations | Medium (~25k tokens) |
| 3.2 | Cross-Navigation | Medium (~30k tokens) |
| 4.1 | Activity System | Medium (~35k tokens) |
| 4.2 | Notes | Medium (~25k tokens) |
| 5.1 | Dashboard Metrics | High (~40k tokens) |
| 5.2 | Dashboard Timeline | Medium (~25k tokens) |
| 6.1 | Global Search | High (~45k tokens) |
| 7.1 | Turbo Enhancements | Medium (~35k tokens) |
| 7.2 | Stimulus Controllers | Medium (~35k tokens) |
| 8.1 | Error Handling | Low (~20k tokens) |
| 8.2 | Performance | Medium (~25k tokens) |
| 8.3 | Deployment | Low (~15k tokens) |

### Key Design Decisions

1. **Semantic HTML First**: All functionality works without JavaScript; Hotwire enhances the experience
2. **37signals Design**: Clean, minimal UI with focus on content and usability
3. **Polymorphic Associations**: Activities and Notes use polymorphic associations for flexibility
4. **Status Workflows**: All entities with status use defined state machines
5. **Soft Navigation**: Turbo Drive for fast page transitions, Turbo Frames for partial updates
6. **Progressive Enhancement**: Stimulus controllers enhance but don't replace browser behavior
