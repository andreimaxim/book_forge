# Caching & Code Quality Improvement Plan

This plan applies the patterns established in `CLAUDE.md` to all pages in the application.

## Phase 1: Convert Constants to Enums (String Storage)

All models using `STATUSES` or similar constants should use enums with `index_by(&:itself)` for string storage.

### 1.1 Author Model
```ruby
# Remove: STATUSES = %w[active inactive deceased].freeze
# Add:
enum :status, %w[active inactive deceased].index_by(&:itself)
```
**Files to update:**
- `app/models/author.rb` - Add enum, remove constant and validation
- `app/views/authors/_filters.html.erb` - Change `Author::STATUSES` to `Author.statuses.keys`
- `app/views/authors/_form.html.erb` - Use helper method
- `app/helpers/authors_helper.rb` - Create `author_status_options` helper

### 1.2 Agent Model
```ruby
# Remove: STATUSES = %w[active inactive not_accepting].freeze
# Add:
enum :status, %w[active inactive not_accepting].index_by(&:itself)
```
**Files to update:**
- `app/models/agent.rb` - Add enum, remove constant and validation
- `app/views/agents/_filters.html.erb` - Change `Agent::STATUSES` to `Agent.statuses.keys`
- `app/views/agents/_form.html.erb` - Use helper method
- `app/helpers/agents_helper.rb` - Create `agent_status_options` helper

### 1.3 Publisher Model
```ruby
# Remove: STATUSES = %w[active inactive].freeze
# Remove: SIZES = %w[big_five major mid_size small indie].freeze
# Add:
enum :status, %w[active inactive].index_by(&:itself)
enum :size, %w[big_five major mid_size small indie].index_by(&:itself)
```
**Files to update:**
- `app/models/publisher.rb` - Add enums, remove constants and validations
- `app/views/publishers/_filters.html.erb` - Update references
- `app/views/publishers/_form.html.erb` - Use helper methods
- `app/helpers/publishers_helper.rb` - Create helper methods

### 1.4 Book Model
```ruby
# Remove: STATUSES = %w[manuscript submitted under_review accepted in_production published out_of_print].freeze
# Remove: FORMATS = %w[hardcover paperback ebook audiobook].freeze
# Add:
enum :status, %w[manuscript submitted under_review accepted in_production published out_of_print].index_by(&:itself)
enum :format, %w[hardcover paperback ebook audiobook].index_by(&:itself)
```
**Files to update:**
- `app/models/book.rb` - Add enums, remove constants and validations
- `app/views/books/_filters.html.erb` - Update references
- `app/views/books/_form.html.erb` - Use helper methods
- `app/views/books/_pipeline.html.erb` - Use `Book.statuses.keys`
- `app/views/books/_status_timeline.html.erb` - Use `Book.statuses.keys`
- `app/helpers/books_helper.rb` - Create helper methods
- `test/controllers/books_controller_test.rb` - Update `Book::STATUSES` references
- `test/models/dashboard/metrics_test.rb` - Update `Book::STATUSES` references
- `app/models/dashboard/metrics.rb` - Update `Book::STATUSES` references

### 1.5 Prospect Model
```ruby
# Remove: STAGES = %w[new contacted evaluating negotiating converted declined].freeze
# Remove: SOURCES = %w[query_letter referral conference social_media website other].freeze
# Add:
enum :stage, %w[new contacted evaluating negotiating converted declined].index_by(&:itself)
enum :source, %w[query_letter referral conference social_media website other].index_by(&:itself)
```
**Files to update:**
- `app/models/prospect.rb` - Add enums, remove constants and validations
- `app/views/prospects/_pipeline.html.erb` - Update references
- `app/views/prospects/_filters.html.erb` - Update references
- `app/views/prospects/_form.html.erb` - Use helper methods
- `app/views/prospects/show.html.erb` - Update references (see Phase 3)
- `app/helpers/prospects_helper.rb` - Create helper methods

### 1.6 Representation Model
```ruby
# Remove: STATUSES = %w[active ended].freeze
# Add:
enum :status, %w[active ended].index_by(&:itself)
```
**Files to update:**
- `app/models/representation.rb` - Add enum, remove constant and validation

### 1.7 Deal Model (DEAL_TYPES only)
```ruby
# Remove: DEAL_TYPES = %w[world_rights north_american translation audio film_tv].freeze
# Add:
enum :deal_type, %w[world_rights north_american translation audio film_tv].index_by(&:itself)
```
**Files to update:**
- `app/models/deal.rb` - Add enum, remove constant and validation
- `app/views/deals/_form.html.erb` - Use helper method
- `app/views/deals/_filters.html.erb` - Update references
- `app/helpers/deals_helper.rb` - Add `deal_type_options` helper

---

## Phase 2: Move Ordering to Model Scopes

Controllers should not know column names. Use scopes instead.

### 2.1 Book Model
```ruby
# Add scope:
scope :recent, -> { order(created_at: :desc) }
```

### 2.2 Author Model
```ruby
# Add scope:
scope :recent, -> { order(updated_at: :desc) }
```

### 2.3 Agent Model
```ruby
# Add scope:
scope :recent, -> { order(updated_at: :desc) }
```

### 2.4 Prospect Model
```ruby
# Add scope:
scope :recent, -> { order(updated_at: :desc) }
```

### 2.5 Update Controllers
| Controller | Current | Change To |
|------------|---------|-----------|
| `authors_controller.rb:15` | `@author.books.order(created_at: :desc)` | `@author.books.recent` |
| `authors_controller.rb:16` | `Deal...order(offer_date: :desc)` | `@author.deals.recent` (after adding association) |
| `agents_controller.rb:16` | `@agent.deals...order(offer_date: :desc)` | `@agent.deals.recent` |
| `books_controller.rb:16` | `@book.deals...order(offer_date: :desc)` | `@book.deals.recent` |

---

## Phase 3: Move View Logic to Models

### 3.1 Prospect Model - Workflow Methods
```ruby
# Add class method:
def self.workflow_stages
  stages.keys - %w[converted declined]
end

# Add instance methods:
def stage_past?(other_stage)
  return false if converted? || declined?
  self.class.workflow_stages.index(stage) > self.class.workflow_stages.index(other_stage)
end

def convertible?
  negotiating?
end

def declinable?
  !converted? && !declined?
end

def follow_up_overdue?
  follow_up_date.present? && follow_up_date < Date.current
end

def follow_up_today?
  follow_up_date.present? && follow_up_date == Date.current
end
```

### 3.2 Update Prospects Show View
**Current (lines 153-174):**
```erb
<% Prospect::STAGES.reject { |s| %w[converted declined].include?(s) }.each_with_index do |stage, index| %>
  <% is_past = Prospect::STAGES.index(@prospect.stage) > Prospect::STAGES.index(stage) %>
```

**Change to:**
```erb
<% Prospect.workflow_stages.each_with_index do |stage, index| %>
  <% is_past = @prospect.stage_past?(stage) %>
```

**Current (lines 32-43):**
```erb
<% unless %w[converted declined].include?(@prospect.stage) %>
  <% if @prospect.stage == "negotiating" %>
```

**Change to:**
```erb
<% if @prospect.declinable? %>
  <% if @prospect.convertible? %>
```

**Current (lines 107-113):**
```erb
<% if @prospect.follow_up_date < Date.today %>
```

**Change to:**
```erb
<% if @prospect.follow_up_overdue? %>
```

### 3.3 Book Model - Status Timeline Methods
```ruby
# Add class method (similar to Deal):
def self.workflow_statuses
  statuses.keys
end

# Add instance method:
def status_past?(other_status)
  self.class.workflow_statuses.index(status) > self.class.workflow_statuses.index(other_status)
end
```

---

## Phase 4: Add Missing Associations

### 4.1 Author Model - Add deals association
```ruby
# Add:
has_many :deals, through: :books
```
This allows `@author.deals` instead of the inline query in the controller.

---

## Phase 5: Implement Turbo Frame Lazy Loading

### 5.1 Authors Show Page
**Current tabs:** Books (default), Deals, Agents, Notes
**Action:** Lazy-load Deals, Agents, Notes tabs

**Routes to add:**
```ruby
resources :authors do
  resource :deals, only: [:show], module: :authors
  resource :agents, only: [:show], module: :authors
  resource :notes, only: [:show], module: :authors
end
```

**Controllers to create:**
- `app/controllers/authors/deals_controller.rb`
- `app/controllers/authors/agents_controller.rb`
- `app/controllers/authors/notes_controller.rb`

**Concern to create:**
- `app/controllers/concerns/author_scoped.rb`

**Update controller:**
```ruby
# authors_controller.rb
def show
  @books = @author.books.recent  # Only load default tab data
end
```

### 5.2 Agents Show Page
**Current tabs:** Authors (default), Deals
**Action:** Lazy-load Deals tab

**Routes to add:**
```ruby
resources :agents do
  resource :deals, only: [:show], module: :agents
end
```

**Controllers to create:**
- `app/controllers/agents/deals_controller.rb`

**Concern to create:**
- `app/controllers/concerns/agent_scoped.rb`

### 5.3 Books Show Page
**Current tabs:** Deals (only tab)
**Action:** Consider lazy-loading if page is heavy, or leave as-is

**Routes to add (optional):**
```ruby
resources :books do
  resource :deals, only: [:show], module: :books
end
```

---

## Phase 6: Create View Helpers

### 6.1 Authors Helper
```ruby
# app/helpers/authors_helper.rb
module AuthorsHelper
  def author_status_options(include_all: false)
    options = Author.statuses.keys.map { |s| [s.humanize, s] }
    include_all ? [["All Statuses", ""]] + options : options
  end
end
```

### 6.2 Agents Helper
```ruby
# app/helpers/agents_helper.rb
module AgentsHelper
  def agent_status_options(include_all: false)
    options = Agent.statuses.keys.map { |s| [s.humanize, s] }
    include_all ? [["All Statuses", ""]] + options : options
  end
end
```

### 6.3 Publishers Helper
```ruby
# app/helpers/publishers_helper.rb
module PublishersHelper
  def publisher_status_options(include_all: false)
    options = Publisher.statuses.keys.map { |s| [s.humanize, s] }
    include_all ? [["All Statuses", ""]] + options : options
  end

  def publisher_size_options(include_all: false)
    options = Publisher.sizes.keys.map { |s| [s.humanize.titleize, s] }
    include_all ? [["All Sizes", ""]] + options : options
  end
end
```

### 6.4 Books Helper
```ruby
# app/helpers/books_helper.rb
module BooksHelper
  def book_status_options(include_all: false)
    options = Book.statuses.keys.map { |s| [s.humanize, s] }
    include_all ? [["All Statuses", ""]] + options : options
  end

  def book_format_options(include_all: false)
    options = Book.formats.keys.map { |s| [s.humanize, s] }
    include_all ? [["All Formats", ""]] + options : options
  end
end
```

### 6.5 Prospects Helper
```ruby
# app/helpers/prospects_helper.rb
module ProspectsHelper
  def prospect_stage_options(include_all: false)
    options = Prospect.stages.keys.map { |s| [s.humanize, s] }
    include_all ? [["All Stages", ""]] + options : options
  end

  def prospect_source_options(include_all: false)
    options = Prospect.sources.keys.map { |s| [s.humanize, s] }
    include_all ? [["All Sources", ""]] + options : options
  end
end
```

### 6.6 Deals Helper (add deal_type)
```ruby
# app/helpers/deals_helper.rb - add:
def deal_type_options(include_all: false)
  options = Deal.deal_types.keys.map { |s| [s.humanize, s] }
  include_all ? [["All Types", ""]] + options : options
end
```

---

## Phase 7: Touch Chain Completion

Verify all touch chains are complete for cache invalidation.

### Current Touch Chain:
```
Author → Books (after_update :touch_books)
Book → Author (belongs_to touch: true)
Book → Deals (after_update :touch_deals)
Deal → Book (belongs_to touch: true)
Deal → Publisher (belongs_to touch: true)
Deal → Agent (belongs_to touch: true)
Note → Notable (belongs_to touch: true)
Representation → Author (belongs_to touch: true)
Representation → Agent (belongs_to touch: true)
```

### Missing Touch Chains to Add:
```ruby
# Agent model - touch representations when agent changes
after_update :touch_representations

private
def touch_representations
  representations.touch_all
end

# Prospect model - if it has related records that need cache busting
# (evaluate based on actual relationships)
```

---

## Phase 8: Remove Intermediate Caching

Review and remove any partial-level caching that's not at the page level.

### Files to Review:
- `app/views/authors/_books_tab.html.erb` - Has `cache book` blocks
- `app/views/authors/_deals_tab.html.erb` - Has `cache [deal, ...]` blocks
- `app/views/books/_deals_tab.html.erb` - Has `cache [deal, ...]` blocks
- `app/views/publishers/_books_tab.html.erb` - Already clean
- `app/views/publishers/_deals_tab.html.erb` - Already clean

**Decision:** Keep item-level caching for now (it's valid Russian doll caching). Remove only if moving to page-level caching.

---

## Implementation Order

1. **Phase 1** - Enums (foundation for everything else)
2. **Phase 2** - Scopes (enables cleaner controllers)
3. **Phase 4** - Associations (enables cleaner queries)
4. **Phase 3** - Model methods (cleans up views)
5. **Phase 6** - Helpers (final view cleanup)
6. **Phase 5** - Lazy loading (performance improvement)
7. **Phase 7** - Touch chains (cache consistency)
8. **Phase 8** - Caching review (final optimization)

---

## Testing Strategy

After each phase:
1. Run `bin/rails test` to verify no regressions
2. Run `bin/rubocop` to check code style
3. Manually verify affected pages load correctly
4. Check Rails logs for query counts

---

## Files Changed Summary

| Phase | Files Modified | Files Created |
|-------|----------------|---------------|
| 1 | ~25 | 0 |
| 2 | ~8 | 0 |
| 3 | ~4 | 0 |
| 4 | 1 | 0 |
| 5 | ~6 | ~8 |
| 6 | 0 | ~5 |
| 7 | ~2 | 0 |
| 8 | ~4 | 0 |
| **Total** | **~50** | **~13** |
