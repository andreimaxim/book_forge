# frozen_string_literal: true

# Seed data for BookForge - Book Publishing CRM
# Run with: bin/rails db:seed
#
# Idempotent: safe to run multiple times.

puts "Seeding BookForge..."

# ---------------------------------------------------------------------------
# Publishers
# ---------------------------------------------------------------------------
publishers = {}

[
  { name: "Penguin Random House", imprint: "Viking", size: "big_five",
    address_line1: "1745 Broadway", city: "New York", state: "NY", postal_code: "10019", country: "USA",
    phone: "212-782-9000", website: "https://www.penguinrandomhouse.com",
    contact_name: "Sarah Mitchell", contact_email: "s.mitchell@prh.com", contact_phone: "212-782-9001",
    notes: "Largest trade book publisher in the world." },
  { name: "HarperCollins", imprint: "Harper Perennial", size: "big_five",
    address_line1: "195 Broadway", city: "New York", state: "NY", postal_code: "10007", country: "USA",
    phone: "212-207-7000", website: "https://www.harpercollins.com",
    contact_name: "David Chen", contact_email: "d.chen@harpercollins.com", contact_phone: "212-207-7001",
    notes: "One of the Big Five English-language publishers." },
  { name: "Simon & Schuster", imprint: "Scribner", size: "big_five",
    address_line1: "1230 Avenue of the Americas", city: "New York", state: "NY", postal_code: "10020", country: "USA",
    phone: "212-698-7000", website: "https://www.simonandschuster.com",
    contact_name: "Rachel Adams", contact_email: "r.adams@simonschuster.com",
    notes: "Founded in 1924." },
  { name: "Hachette Book Group", imprint: "Little, Brown", size: "big_five",
    address_line1: "1290 Avenue of the Americas", city: "New York", state: "NY", postal_code: "10104", country: "USA",
    phone: "212-364-1100", website: "https://www.hachettebookgroup.com",
    contact_name: "James Park", contact_email: "j.park@hachette.com",
    notes: "US arm of Hachette Livre, a subsidiary of Lagardère." },
  { name: "Macmillan Publishers", imprint: "Farrar, Straus and Giroux", size: "big_five",
    address_line1: "120 Broadway", city: "New York", state: "NY", postal_code: "10271", country: "USA",
    phone: "646-307-5151", website: "https://us.macmillan.com",
    contact_name: "Maria Gonzalez", contact_email: "m.gonzalez@macmillan.com",
    notes: "Known for literary fiction and nonfiction." },
  { name: "Scholastic Corporation", size: "major",
    address_line1: "557 Broadway", city: "New York", state: "NY", postal_code: "10012", country: "USA",
    phone: "212-343-6100", website: "https://www.scholastic.com",
    contact_name: "Linda Torres", contact_email: "l.torres@scholastic.com",
    notes: "Largest publisher and distributor of children's books." },
  { name: "Chronicle Books", size: "mid_size",
    address_line1: "680 Second Street", city: "San Francisco", state: "CA", postal_code: "94107", country: "USA",
    phone: "415-537-4200", website: "https://www.chroniclebooks.com",
    contact_name: "Kevin Yao", contact_email: "k.yao@chroniclebooks.com",
    notes: "Publishes illustrated books, stationery, and gifts." },
  { name: "Graywolf Press", size: "small",
    address_line1: "250 Third Avenue North, Suite 600", city: "Minneapolis", state: "MN", postal_code: "55401", country: "USA",
    phone: "651-641-0077", website: "https://www.graywolfpress.org",
    contact_name: "Fiona Kelly", contact_email: "f.kelly@graywolfpress.org",
    notes: "Independent nonprofit publisher focused on literary fiction, nonfiction, and poetry." },
  { name: "Tin House Books", size: "indie",
    address_line1: "2617 NW Thurman St.", city: "Portland", state: "OR", postal_code: "97210", country: "USA",
    website: "https://tinhouse.com",
    contact_name: "Nate Robinson", contact_email: "n.robinson@tinhouse.com",
    notes: "Literary press with roots in the Tin House literary magazine." },
  { name: "Bloomsbury Publishing", size: "major",
    address_line1: "1385 Broadway, 5th Floor", city: "New York", state: "NY", postal_code: "10018", country: "USA",
    phone: "212-419-5300", website: "https://www.bloomsbury.com",
    contact_name: "Oliver Grant", contact_email: "o.grant@bloomsbury.com",
    notes: "Known internationally for publishing the Harry Potter series." },
  { name: "Europa Editions", size: "small",
    address_line1: "214 West 29th Street, Suite 1003", city: "New York", state: "NY", postal_code: "10001", country: "USA",
    website: "https://www.europaeditions.com",
    contact_name: "Sofia Ricci", contact_email: "s.ricci@europaeditions.com",
    notes: "Specialises in international literary fiction in translation." },
  { name: "Defunct Publishing Co.", size: "small", status: "inactive",
    city: "Boston", state: "MA", country: "USA",
    notes: "Closed operations in 2023." }
].each do |attrs|
  pub = Publisher.find_or_create_by!(name: attrs[:name]) do |p|
    attrs.except(:name).each { |k, v| p.send(:"#{k}=", v) }
  end
  publishers[pub.name] = pub
end

puts "  Created #{Publisher.count} publishers"

# ---------------------------------------------------------------------------
# Agents
# ---------------------------------------------------------------------------
agents = {}

[
  { first_name: "Simon", last_name: "Lipskar", email: "simon@writershouse.com",
    phone: "212-685-2400", agency_name: "Writers House", agency_website: "https://writershouse.com",
    address_line1: "21 West 26th Street", city: "New York", state: "NY", postal_code: "10010",
    commission_rate: 15.0, genres_represented: "Fantasy, Science Fiction, Literary Fiction, Young Adult",
    notes: "Represents bestselling fantasy and YA authors." },
  { first_name: "Esther", last_name: "Newberg", email: "esther@icmpartners.com",
    phone: "212-556-5600", agency_name: "ICM Partners", agency_website: "https://www.icmpartners.com",
    address_line1: "65 East 55th Street", city: "New York", state: "NY", postal_code: "10022",
    commission_rate: 15.0, genres_represented: "Literary Fiction, Nonfiction, Memoir",
    notes: "One of the most powerful literary agents in New York." },
  { first_name: "Jennifer", last_name: "Joel", email: "jennifer.joel@icmpartners.com",
    phone: "212-556-5601", agency_name: "ICM Partners", agency_website: "https://www.icmpartners.com",
    address_line1: "65 East 55th Street", city: "New York", state: "NY", postal_code: "10022",
    commission_rate: 15.0, genres_represented: "Literary Fiction, Historical Fiction, Nonfiction",
    notes: "Colleagues with Esther Newberg at ICM." },
  { first_name: "Molly", last_name: "Friedrich", email: "molly@friedlit.com",
    phone: "212-317-8810", agency_name: "The Friedrich Agency", agency_website: "https://friedrichagency.com",
    address_line1: "136 East 57th Street, 14th Floor", city: "New York", state: "NY", postal_code: "10022",
    commission_rate: 15.0, genres_represented: "Literary Fiction, Mystery, Thriller, Women's Fiction",
    notes: "Represents many bestselling novelists." },
  { first_name: "Emily", last_name: "Davis", email: "emily@romancelit.com",
    phone: "212-555-0101", agency_name: "Romance Literary Agency",
    commission_rate: 12.5, genres_represented: "Romance, Women's Fiction",
    city: "New York", state: "NY",
    notes: "Specialises in romance and women's fiction." },
  { first_name: "Robert", last_name: "Gottlieb", email: "robert@tridentmg.com",
    phone: "212-333-1511", agency_name: "Trident Media Group", agency_website: "https://www.tridentmediagroup.com",
    address_line1: "355 Lexington Avenue, Floor 12", city: "New York", state: "NY", postal_code: "10017",
    commission_rate: 15.0, genres_represented: "Thriller, Horror, Mystery, True Crime",
    notes: "Strong track record in genre fiction." },
  { first_name: "Sarah", last_name: "Thompson", email: "sarah@mysteryliteraryagency.com",
    phone: "310-555-0202", agency_name: "Mystery Literary Agency",
    commission_rate: 15.0, genres_represented: "Mystery, Crime Fiction, Thriller",
    city: "Los Angeles", state: "CA",
    notes: "West Coast agent focused on crime and mystery." },
  { first_name: "David", last_name: "Halpern", email: "david@therga.com",
    phone: "212-765-6900", agency_name: "The Robbins Office", agency_website: "https://www.robbinsoffice.com",
    city: "New York", state: "NY",
    commission_rate: 15.0, genres_represented: "Literary Fiction, Nonfiction, Biography",
    notes: "Boutique agency with a curated list." },
  { first_name: "Patricia", last_name: "Lee", email: "patricia@leeliterary.com",
    phone: "415-555-0303", agency_name: "Lee Literary",
    commission_rate: 10.0, genres_represented: "Science Fiction, Fantasy, Speculative Fiction",
    city: "San Francisco", state: "CA", status: "not_accepting",
    notes: "Currently not accepting new clients. List is full." },
  { first_name: "Marcus", last_name: "Finch", email: "marcus@finchagency.com",
    agency_name: "Finch Literary Agency",
    commission_rate: 15.0, genres_represented: "Children's, Middle Grade, Young Adult",
    city: "Chicago", state: "IL", status: "inactive",
    notes: "Retired from agenting in late 2024." }
].each do |attrs|
  ag = Agent.find_or_create_by!(email: attrs[:email]) do |a|
    attrs.except(:email).each { |k, v| a.send(:"#{k}=", v) }
  end
  agents[ag.email] = ag
end

puts "  Created #{Agent.count} agents"

# ---------------------------------------------------------------------------
# Authors
# ---------------------------------------------------------------------------
authors = {}

[
  { first_name: "Margaret", last_name: "Atwood", email: "m.atwood@authors.example.com",
    bio: "Canadian poet, novelist, literary critic, and inventor. Known for her dystopian and speculative fiction.",
    website: "https://margaretatwood.ca", genre_focus: "Literary Fiction",
    date_of_birth: Date.new(1939, 11, 18), status: "active",
    notes: "Booker Prize winner. Known for The Handmaid's Tale." },
  { first_name: "Colson", last_name: "Whitehead", email: "c.whitehead@authors.example.com",
    bio: "American novelist. Won the Pulitzer Prize for Fiction twice.",
    website: "https://colsonwhitehead.com", genre_focus: "Literary Fiction",
    date_of_birth: Date.new(1969, 11, 6), status: "active",
    notes: "The Underground Railroad, The Nickel Boys." },
  { first_name: "Donna", last_name: "Tartt", email: "d.tartt@authors.example.com",
    bio: "American author known for meticulous prose and long gaps between novels.",
    genre_focus: "Literary Fiction",
    date_of_birth: Date.new(1963, 12, 23), status: "active",
    notes: "Pulitzer Prize for The Goldfinch." },
  { first_name: "Brandon", last_name: "Sanderson", email: "b.sanderson@authors.example.com",
    bio: "American author of epic fantasy and science fiction.",
    website: "https://www.brandonsanderson.com", genre_focus: "Fantasy",
    date_of_birth: Date.new(1975, 12, 19), status: "active",
    notes: "Prolific output. Cosmere universe. Record-breaking Kickstarter." },
  { first_name: "Tana", last_name: "French", email: "t.french@authors.example.com",
    bio: "Irish-American author best known for the Dublin Murder Squad series.",
    genre_focus: "Mystery",
    date_of_birth: Date.new(1973, 6, 10), status: "active",
    notes: "In the Woods, The Likeness, Faithful Place." },
  { first_name: "Hanya", last_name: "Yanagihara", email: "h.yanagihara@authors.example.com",
    bio: "American novelist and editor at T: The New York Times Style Magazine.",
    genre_focus: "Literary Fiction",
    date_of_birth: Date.new(1974, 9, 20), status: "active",
    notes: "A Little Life was a National Book Award finalist." },
  { first_name: "N.K.", last_name: "Jemisin", email: "nk.jemisin@authors.example.com",
    bio: "First author to win the Hugo Award for Best Novel three years in a row.",
    website: "https://nkjemisin.com", genre_focus: "Science Fiction",
    date_of_birth: Date.new(1972, 9, 19), status: "active",
    notes: "The Broken Earth trilogy." },
  { first_name: "Sally", last_name: "Rooney", email: "s.rooney@authors.example.com",
    bio: "Irish author and screenwriter.",
    genre_focus: "Literary Fiction",
    date_of_birth: Date.new(1991, 2, 20), status: "active",
    notes: "Normal People, Beautiful World Where Are You." },
  { first_name: "James", last_name: "Ellroy", email: "j.ellroy@authors.example.com",
    bio: "American crime fiction writer and essayist.",
    genre_focus: "Crime Fiction",
    date_of_birth: Date.new(1948, 3, 4), status: "active",
    notes: "L.A. Confidential, American Tabloid." },
  { first_name: "Octavia", last_name: "Butler", email: "o.butler@authors.example.com",
    bio: "Pioneering African American science fiction author.",
    genre_focus: "Science Fiction",
    date_of_birth: Date.new(1947, 6, 22), status: "deceased",
    notes: "MacArthur Fellow. Kindred, Parable of the Sower." },
  { first_name: "Elena", last_name: "Ferrante", email: "e.ferrante@authors.example.com",
    bio: "Pseudonymous Italian novelist.",
    genre_focus: "Literary Fiction",
    status: "active",
    notes: "The Neapolitan Novels." },
  { first_name: "R.F.", last_name: "Kuang", email: "rf.kuang@authors.example.com",
    bio: "American fantasy and speculative fiction author.",
    website: "https://www.rfkuang.com", genre_focus: "Fantasy",
    date_of_birth: Date.new(1996, 5, 29), status: "active",
    notes: "Babel, Yellowface, The Poppy War trilogy." },
  { first_name: "Patricia", last_name: "Highsmith",
    bio: "American novelist and short story writer noted for psychological thrillers.",
    genre_focus: "Thriller",
    date_of_birth: Date.new(1921, 1, 19), status: "deceased",
    notes: "The Talented Mr. Ripley, Strangers on a Train." },
  { first_name: "Thomas", last_name: "Pynchon", email: "t.pynchon@authors.example.com",
    bio: "Reclusive American novelist noted for complex, dense novels.",
    genre_focus: "Literary Fiction",
    date_of_birth: Date.new(1937, 5, 8), status: "inactive",
    notes: "Gravity's Rainbow, The Crying of Lot 49." }
].each do |attrs|
  key = "#{attrs[:first_name]} #{attrs[:last_name]}"
  au = Author.find_or_create_by!(first_name: attrs[:first_name], last_name: attrs[:last_name]) do |a|
    attrs.except(:first_name, :last_name).each { |k, v| a.send(:"#{k}=", v) }
  end
  authors[key] = au
end

puts "  Created #{Author.count} authors"

# ---------------------------------------------------------------------------
# Books
# ---------------------------------------------------------------------------
books = {}

book_data = [
  # Margaret Atwood
  { title: "The Handmaid's Tale", author: "Margaret Atwood", genre: "Dystopian Fiction", subgenre: "Speculative",
    word_count: 90_240, status: "published", isbn: "978-0-385-49081-8", format: "paperback",
    publication_date: Date.new(1985, 9, 1), list_price: 16.99, page_count: 311,
    synopsis: "Set in a near-future New England in a totalitarian state that has overthrown the US government.",
    notes: "Adapted into a Hulu series." },
  { title: "The Testaments", author: "Margaret Atwood", genre: "Dystopian Fiction", subgenre: "Speculative",
    word_count: 103_000, status: "published", isbn: "978-0-385-54378-1", format: "hardcover",
    publication_date: Date.new(2019, 9, 10), list_price: 28.95, page_count: 422,
    synopsis: "Sequel to The Handmaid's Tale, set 15 years after the events of the first novel." },

  # Colson Whitehead
  { title: "The Underground Railroad", author: "Colson Whitehead", genre: "Historical Fiction",
    word_count: 80_000, status: "published", isbn: "978-0-385-54236-4", format: "paperback",
    publication_date: Date.new(2016, 8, 2), list_price: 16.95, page_count: 306,
    synopsis: "A young enslaved woman makes a desperate bid for freedom via the Underground Railroad." },
  { title: "The Nickel Boys", author: "Colson Whitehead", genre: "Historical Fiction",
    word_count: 56_000, status: "published", isbn: "978-0-385-53721-6", format: "hardcover",
    publication_date: Date.new(2019, 7, 16), list_price: 24.95, page_count: 224,
    synopsis: "Based on the real story of a reform school in Jim Crow-era Florida." },

  # Brandon Sanderson
  { title: "The Way of Kings", author: "Brandon Sanderson", genre: "Fantasy", subgenre: "Epic Fantasy",
    word_count: 383_000, status: "published", isbn: "978-0-7653-2635-5", format: "hardcover",
    publication_date: Date.new(2010, 8, 31), list_price: 27.99, page_count: 1007,
    synopsis: "First book of The Stormlight Archive." },
  { title: "Wind and Truth", author: "Brandon Sanderson", genre: "Fantasy", subgenre: "Epic Fantasy",
    word_count: 460_000, status: "in_production", format: "hardcover",
    synopsis: "Fifth book of The Stormlight Archive. Highly anticipated conclusion to the first arc.",
    notes: "Expected to be the longest Stormlight book." },

  # Tana French
  { title: "In the Woods", author: "Tana French", genre: "Mystery", subgenre: "Crime Fiction",
    word_count: 120_000, status: "published", isbn: "978-0-14-311349-7", format: "paperback",
    publication_date: Date.new(2007, 5, 17), list_price: 17.00, page_count: 429,
    synopsis: "Detective Rob Ryan investigates a murder in the Dublin suburbs." },
  { title: "The Hunter", author: "Tana French", genre: "Mystery", subgenre: "Literary Thriller",
    word_count: 95_000, status: "published", isbn: "978-0-593-29740-5", format: "hardcover",
    publication_date: Date.new(2024, 3, 5), list_price: 29.00, page_count: 352,
    synopsis: "A retired detective in rural Ireland is drawn into investigating a cold case." },

  # N.K. Jemisin
  { title: "The Fifth Season", author: "N.K. Jemisin", genre: "Science Fiction", subgenre: "Fantasy",
    word_count: 100_000, status: "published", isbn: "978-0-316-22929-6", format: "paperback",
    publication_date: Date.new(2015, 8, 4), list_price: 16.99, page_count: 468,
    synopsis: "On a planet with a single supercontinent called the Stillness, every few centuries a catastrophic seismic event occurs." },

  # Sally Rooney
  { title: "Normal People", author: "Sally Rooney", genre: "Literary Fiction", subgenre: "Contemporary",
    word_count: 67_000, status: "published", isbn: "978-1-984-82258-1", format: "paperback",
    publication_date: Date.new(2019, 4, 16), list_price: 17.00, page_count: 273,
    synopsis: "The complicated relationship of Connell and Marianne from school through university in Dublin." },
  { title: "Intermezzo", author: "Sally Rooney", genre: "Literary Fiction", subgenre: "Contemporary",
    word_count: 85_000, status: "published", isbn: "978-0-374-60263-1", format: "hardcover",
    publication_date: Date.new(2024, 9, 24), list_price: 29.00, page_count: 432,
    synopsis: "Two brothers navigate grief, love and their relationship with each other." },

  # R.F. Kuang
  { title: "Babel", author: "R.F. Kuang", genre: "Fantasy", subgenre: "Historical Fantasy",
    word_count: 170_000, status: "published", isbn: "978-0-06-302143-3", format: "hardcover",
    publication_date: Date.new(2022, 8, 23), list_price: 27.99, page_count: 560,
    synopsis: "Set in 1830s Oxford, translation and the power of language fuel the British Empire." },
  { title: "Yellowface", author: "R.F. Kuang", genre: "Literary Fiction", subgenre: "Satire",
    word_count: 75_000, status: "published", isbn: "978-0-06-303607-9", format: "hardcover",
    publication_date: Date.new(2023, 5, 16), list_price: 27.99, page_count: 336,
    synopsis: "A scathing satire of the publishing industry, identity, and fraud." },

  # James Ellroy
  { title: "L.A. Confidential", author: "James Ellroy", genre: "Crime Fiction", subgenre: "Noir",
    word_count: 170_000, status: "published", isbn: "978-0-446-67424-8", format: "paperback",
    publication_date: Date.new(1990, 6, 1), list_price: 17.99, page_count: 496,
    synopsis: "Three LAPD officers investigate a mass murder at a coffee shop in 1950s Los Angeles." },

  # Elena Ferrante
  { title: "My Brilliant Friend", author: "Elena Ferrante", genre: "Literary Fiction",
    word_count: 90_000, status: "published", isbn: "978-1-609-45078-9", format: "paperback",
    publication_date: Date.new(2012, 9, 25), list_price: 17.00, page_count: 331,
    synopsis: "The first book in the Neapolitan Novels following two friends growing up in post-war Naples." },

  # Works in progress / not yet published
  { title: "Untitled Atwood Novel", author: "Margaret Atwood", genre: "Literary Fiction",
    word_count: 35_000, status: "manuscript",
    synopsis: "An early draft exploring themes of environmental collapse and memory.",
    notes: "First draft. Author has not committed to a delivery date." },
  { title: "The Distant Shore", author: "Hanya Yanagihara", genre: "Literary Fiction",
    word_count: 120_000, status: "submitted",
    synopsis: "A multi-generational saga spanning three continents.",
    notes: "Submitted to multiple publishers." },
  { title: "Dublin Requiem", author: "Tana French", genre: "Mystery",
    word_count: 80_000, status: "under_review",
    synopsis: "A standalone mystery set during the Celtic Tiger era.",
    notes: "Under review at two publishing houses." },
  { title: "Stormweaver", author: "Brandon Sanderson", genre: "Fantasy", subgenre: "Epic Fantasy",
    word_count: 200_000, status: "accepted",
    synopsis: "A new Cosmere novel set on a previously unexplored world.",
    notes: "Accepted by Tor. Delivery expected next year." },
  { title: "The Forgotten City", author: "N.K. Jemisin", genre: "Science Fiction",
    word_count: 95_000, status: "accepted",
    synopsis: "Near-future science fiction set in a transformed New York City.",
    notes: "Sequel to The City We Became." }
].each do |attrs|
  author_name = attrs.delete(:author)
  author = authors[author_name]
  bk = Book.find_or_create_by!(title: attrs[:title], author: author) do |b|
    attrs.except(:title).each { |k, v| b.send(:"#{k}=", v) }
  end
  books[bk.title] = bk
end

puts "  Created #{Book.count} books"

# ---------------------------------------------------------------------------
# Deals
# ---------------------------------------------------------------------------
deal_data = [
  { book: "The Handmaid's Tale", publisher: "Hachette Book Group", agent_email: "esther@icmpartners.com",
    deal_type: "world_rights", advance_amount: 50_000, status: "completed",
    royalty_rate_hardcover: 10.0, royalty_rate_paperback: 7.5, royalty_rate_ebook: 25.0,
    offer_date: Date.new(1984, 6, 1), contract_date: Date.new(1984, 7, 15),
    terms_summary: "Original deal for Handmaid's Tale, pre-fame." },
  { book: "The Testaments", publisher: "Penguin Random House", agent_email: "esther@icmpartners.com",
    deal_type: "world_rights", advance_amount: 2_000_000, status: "active",
    royalty_rate_hardcover: 15.0, royalty_rate_paperback: 10.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2018, 11, 1), contract_date: Date.new(2019, 1, 10),
    delivery_date: Date.new(2019, 5, 1), publication_date: Date.new(2019, 9, 10),
    terms_summary: "Major deal for the Handmaid's Tale sequel." },
  { book: "The Underground Railroad", publisher: "Penguin Random House", agent_email: "molly@friedlit.com",
    deal_type: "world_rights", advance_amount: 675_000, status: "active",
    royalty_rate_hardcover: 15.0, royalty_rate_paperback: 10.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2015, 3, 1), contract_date: Date.new(2015, 4, 20),
    terms_summary: "Two-book deal including The Nickel Boys." },
  { book: "The Nickel Boys", publisher: "Penguin Random House", agent_email: "molly@friedlit.com",
    deal_type: "north_american", advance_amount: 500_000, status: "active",
    royalty_rate_hardcover: 15.0, royalty_rate_paperback: 10.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2015, 3, 1), contract_date: Date.new(2015, 4, 20),
    terms_summary: "Part of the two-book deal." },
  { book: "The Way of Kings", publisher: "Macmillan Publishers", agent_email: "simon@writershouse.com",
    deal_type: "world_rights", advance_amount: 300_000, status: "active",
    royalty_rate_hardcover: 12.5, royalty_rate_paperback: 8.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2008, 1, 15), contract_date: Date.new(2008, 3, 1),
    terms_summary: "Multi-book deal for The Stormlight Archive." },
  { book: "Wind and Truth", publisher: "Macmillan Publishers", agent_email: "simon@writershouse.com",
    deal_type: "world_rights", advance_amount: 1_500_000, status: "signed",
    royalty_rate_hardcover: 15.0, royalty_rate_paperback: 10.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2023, 6, 1), contract_date: Date.new(2023, 8, 15),
    terms_summary: "Premium advance reflecting Sanderson's market position." },
  { book: "Normal People", publisher: "Penguin Random House", agent_email: "jennifer.joel@icmpartners.com",
    deal_type: "world_rights", advance_amount: 800_000, status: "active",
    royalty_rate_hardcover: 12.5, royalty_rate_paperback: 10.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2018, 1, 10), contract_date: Date.new(2018, 3, 1),
    terms_summary: "Breakthrough deal for Sally Rooney." },
  { book: "Normal People", publisher: "Hachette Book Group",
    deal_type: "audio", advance_amount: 150_000, status: "active",
    offer_date: Date.new(2018, 5, 1), contract_date: Date.new(2018, 6, 15),
    terms_summary: "Audiobook rights for Normal People." },
  { book: "Intermezzo", publisher: "Macmillan Publishers", agent_email: "jennifer.joel@icmpartners.com",
    deal_type: "north_american", advance_amount: 1_200_000, status: "active",
    royalty_rate_hardcover: 15.0, royalty_rate_paperback: 10.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2023, 4, 1), contract_date: Date.new(2023, 5, 20),
    terms_summary: "Significant advance reflecting Rooney's growing readership." },
  { book: "Babel", publisher: "HarperCollins", agent_email: "simon@writershouse.com",
    deal_type: "world_rights", advance_amount: 450_000, status: "active",
    royalty_rate_hardcover: 12.5, royalty_rate_paperback: 8.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2021, 1, 15), contract_date: Date.new(2021, 3, 1),
    terms_summary: "Two-book deal for Babel and Yellowface." },
  { book: "Yellowface", publisher: "HarperCollins", agent_email: "simon@writershouse.com",
    deal_type: "world_rights", advance_amount: 350_000, status: "active",
    royalty_rate_hardcover: 12.5, royalty_rate_paperback: 8.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2021, 1, 15), contract_date: Date.new(2021, 3, 1),
    terms_summary: "Part of the two-book deal with Babel." },
  { book: "My Brilliant Friend", publisher: "Europa Editions",
    deal_type: "translation", advance_amount: 120_000, status: "completed",
    royalty_rate_paperback: 10.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2011, 6, 1), contract_date: Date.new(2011, 8, 10),
    terms_summary: "English translation rights for the Neapolitan quartet." },
  { book: "The Fifth Season", publisher: "Hachette Book Group", agent_email: "simon@writershouse.com",
    deal_type: "world_rights", advance_amount: 200_000, status: "active",
    royalty_rate_hardcover: 10.0, royalty_rate_paperback: 8.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2014, 2, 1), contract_date: Date.new(2014, 4, 1),
    terms_summary: "Three-book deal for The Broken Earth trilogy." },
  { book: "The Distant Shore", publisher: "Penguin Random House", agent_email: "esther@icmpartners.com",
    deal_type: "world_rights", advance_amount: 900_000, status: "negotiating",
    offer_date: Date.new(2025, 10, 1),
    terms_summary: "Offer made, negotiations ongoing." },
  { book: "Dublin Requiem", publisher: "Simon & Schuster", agent_email: "molly@friedlit.com",
    deal_type: "north_american", advance_amount: 400_000, status: "pending_contract",
    offer_date: Date.new(2025, 11, 15),
    terms_summary: "Verbal agreement reached. Contract being drafted." },
  { book: "Stormweaver", publisher: "Macmillan Publishers", agent_email: "simon@writershouse.com",
    deal_type: "world_rights", advance_amount: 2_500_000, status: "signed",
    royalty_rate_hardcover: 15.0, royalty_rate_paperback: 10.0, royalty_rate_ebook: 25.0,
    offer_date: Date.new(2025, 6, 1), contract_date: Date.new(2025, 8, 1),
    delivery_date: Date.new(2026, 12, 1),
    terms_summary: "Premium advance for new Cosmere novel." },
  { book: "L.A. Confidential", publisher: "Hachette Book Group",
    deal_type: "film_tv", advance_amount: 750_000, status: "completed",
    offer_date: Date.new(1994, 1, 1), contract_date: Date.new(1994, 3, 1),
    terms_summary: "Film rights optioned. Became the 1997 film." }
]

deal_data.each do |attrs|
  book = books[attrs.delete(:book)]
  pub = publishers[attrs.delete(:publisher)]
  agent_email = attrs.delete(:agent_email)
  agent = agent_email ? agents[agent_email] : nil

  Deal.find_or_create_by!(book: book, publisher: pub) do |d|
    d.agent = agent
    attrs.each { |k, v| d.send(:"#{k}=", v) }
  end
end

puts "  Created #{Deal.count} deals"

# ---------------------------------------------------------------------------
# Representations (Author-Agent relationships)
# ---------------------------------------------------------------------------
[
  { author: "Margaret Atwood", agent_email: "esther@icmpartners.com", primary: true,
    start_date: Date.new(1985, 1, 1), notes: "Long-standing representation." },
  { author: "Colson Whitehead", agent_email: "molly@friedlit.com", primary: true,
    start_date: Date.new(2009, 3, 1), notes: "Representing all works." },
  { author: "Brandon Sanderson", agent_email: "simon@writershouse.com", primary: true,
    start_date: Date.new(2003, 6, 1), notes: "Representing since early career." },
  { author: "Tana French", agent_email: "molly@friedlit.com", primary: true,
    start_date: Date.new(2006, 1, 15), notes: "All Dublin Murder Squad and standalone novels." },
  { author: "N.K. Jemisin", agent_email: "simon@writershouse.com", primary: true,
    start_date: Date.new(2010, 5, 1), notes: "All Broken Earth and Great Cities novels." },
  { author: "Sally Rooney", agent_email: "jennifer.joel@icmpartners.com", primary: true,
    start_date: Date.new(2017, 1, 1), notes: "US representation." },
  { author: "R.F. Kuang", agent_email: "simon@writershouse.com", primary: true,
    start_date: Date.new(2017, 9, 1), notes: "Representing since debut." },
  { author: "Hanya Yanagihara", agent_email: "esther@icmpartners.com", primary: true,
    start_date: Date.new(2013, 1, 1) },
  { author: "James Ellroy", agent_email: "robert@tridentmg.com", primary: true,
    start_date: Date.new(1987, 6, 1), notes: "All crime fiction." },
  { author: "Donna Tartt", agent_email: "jennifer.joel@icmpartners.com", primary: true,
    start_date: Date.new(1992, 1, 1), notes: "Representing since The Secret History." },
  # Ended representation
  { author: "Margaret Atwood", agent_email: "molly@friedlit.com",
    start_date: Date.new(1978, 1, 1), end_date: Date.new(1984, 12, 31), status: "ended",
    notes: "Early career representation before moving to ICM." }
].each do |attrs|
  author = authors[attrs.delete(:author)]
  agent = agents[attrs.delete(:agent_email)]

  Representation.find_or_create_by!(author: author, agent: agent) do |r|
    attrs.each { |k, v| r.send(:"#{k}=", v) }
  end
end

puts "  Created #{Representation.count} representations"

# ---------------------------------------------------------------------------
# Prospects
# ---------------------------------------------------------------------------
prospect_agent = agents["simon@writershouse.com"]
evaluating_agent = agents["molly@friedlit.com"]
negotiating_agent = agents["emily@romancelit.com"]

[
  { first_name: "Jordan", last_name: "Blake", email: "jordan.blake@example.com",
    phone: "555-0101", source: "query_letter", stage: "new",
    genre_interest: "Fantasy", project_title: "The Shattered Crown",
    project_description: "An epic fantasy set in a world where monarchs derive power from gemstones.",
    estimated_word_count: 120_000,
    notes: "Strong query letter. Interesting premise." },
  { first_name: "Aisha", last_name: "Patel", email: "aisha.patel@example.com",
    phone: "555-0102", source: "referral", stage: "contacted", agent: prospect_agent,
    genre_interest: "Literary Fiction", project_title: "Monsoon Season",
    project_description: "A multigenerational family saga set between Mumbai and London.",
    estimated_word_count: 95_000,
    last_contact_date: 3.days.ago.to_date, follow_up_date: 2.days.from_now.to_date,
    notes: "Referred by Colson Whitehead. Very promising writer." },
  { first_name: "Marcus", last_name: "Williams", email: "marcus.williams@example.com",
    source: "conference", stage: "evaluating", agent: evaluating_agent,
    genre_interest: "Mystery", project_title: "Buried Verdict",
    project_description: "A legal thriller about a defense attorney who discovers her client is truly guilty.",
    estimated_word_count: 85_000,
    last_contact_date: 1.week.ago.to_date, follow_up_date: Date.today,
    notes: "Met at ThrillerFest. Manuscript under review." },
  { first_name: "Lena", last_name: "Kowalski", email: "lena.kowalski@example.com",
    phone: "555-0104", source: "social_media", stage: "negotiating", agent: negotiating_agent,
    genre_interest: "Romance", project_title: "The Paris Arrangement",
    project_description: "A fake-dating romance set among rival chefs in Paris.",
    estimated_word_count: 78_000,
    last_contact_date: Date.today, follow_up_date: 3.days.from_now.to_date,
    notes: "Strong social media following. Agent is negotiating terms." },
  { first_name: "Derek", last_name: "Okafor", email: "derek.okafor@example.com",
    source: "website", stage: "new",
    genre_interest: "Science Fiction", project_title: "Orbit Decay",
    project_description: "Hard sci-fi about a space station crew dealing with a mysterious signal.",
    estimated_word_count: 105_000,
    notes: "Submitted through the website form." },
  { first_name: "Samantha", last_name: "Reeves", email: "sam.reeves@example.com",
    phone: "555-0106", source: "referral", stage: "contacted", agent: prospect_agent,
    genre_interest: "Literary Fiction", project_title: "The Glass Garden",
    project_description: "A quiet, character-driven novel about grief and botanical illustration.",
    estimated_word_count: 72_000,
    last_contact_date: 5.days.ago.to_date, follow_up_date: 1.day.ago.to_date,
    notes: "Follow-up overdue. Need to schedule a call." },
  { first_name: "Carlos", last_name: "Mendez",
    source: "query_letter", stage: "new",
    genre_interest: "Thriller", project_title: "Border Run",
    project_description: "A cartel thriller set along the US-Mexico border.",
    estimated_word_count: 88_000,
    notes: "No contact info provided beyond the query. Need to follow up." },
  { first_name: "Nina", last_name: "Volkov", email: "nina.volkov@example.com",
    source: "conference", stage: "declined",
    genre_interest: "Horror", project_title: "The Hollow",
    project_description: "A folk horror novel set in rural Appalachia.",
    estimated_word_count: 70_000,
    decline_reason: "Manuscript needs significant revision. Encouraged to resubmit next year.",
    notes: "Good concept but execution needs work." },
  { first_name: "Wei", last_name: "Zhang", email: "wei.zhang@example.com",
    source: "referral", stage: "converted",
    genre_interest: "Fantasy", project_title: "The Jade Archive",
    project_description: "A Chinese-inspired fantasy about archivists who preserve magical histories.",
    estimated_word_count: 110_000,
    notes: "Successfully converted to author. Representation signed." }
].each do |attrs|
  Prospect.find_or_create_by!(first_name: attrs[:first_name], last_name: attrs[:last_name]) do |p|
    attrs.except(:first_name, :last_name).each { |k, v| p.send(:"#{k}=", v) }
  end
end

puts "  Created #{Prospect.count} prospects"

# ---------------------------------------------------------------------------
# Notes
# ---------------------------------------------------------------------------
note_targets = [
  { notable: authors["Margaret Atwood"], content: "Had a productive call about the new manuscript direction. She's leaning toward a more experimental structure.", pinned: true },
  { notable: authors["Margaret Atwood"], content: "Atwood mentioned interest in a podcast series to promote the new book. Follow up with marketing team." },
  { notable: authors["Brandon Sanderson"], content: "**Kickstarter update:** The secret project books shipped successfully. Sanderson's direct-to-fan model continues to impress.\n\nKey takeaways:\n- 185,000+ backers\n- $41M+ raised\n- All four books delivered on schedule", pinned: true },
  { notable: authors["Sally Rooney"], content: "Intermezzo launch event planned for September. Venue TBD. Need to coordinate with publisher on timing." },
  { notable: books["The Handmaid's Tale"], content: "New edition with updated introduction is under discussion for the 40th anniversary." },
  { notable: books["Babel"], content: "Translation rights generating strong interest from European publishers. Germany and France deals close to closing." },
  { notable: publishers["Penguin Random House"], content: "Annual review meeting scheduled for Q1. Prepare deal pipeline summary and YTD numbers.\n\n**Topics to discuss:**\n1. New author acquisitions\n2. Digital-first strategy\n3. Audio rights bundling", pinned: true },
  { notable: publishers["Europa Editions"], content: "Looking to expand their English-language original fiction list. Good opportunity for literary fiction submissions." },
  { notable: Deal.find_by(book: books["Wind and Truth"]), content: "Delivery date confirmed. Sanderson is ahead of schedule as usual. Marketing plan being developed.", pinned: true },
  { notable: Deal.find_by(book: books["The Distant Shore"]), content: "Counter-offer sent. Awaiting publisher response. Expected within the week." },
  { notable: agents["simon@writershouse.com"], content: "Simon mentioned he's looking for more diverse voices in fantasy and sci-fi. Send him the Shattered Crown query." },
  { notable: agents["molly@friedlit.com"], content: "Molly will be at the Frankfurt Book Fair. Schedule a meeting to discuss foreign rights strategy." }
]

note_targets.each do |attrs|
  next unless attrs[:notable]
  Note.find_or_create_by!(notable: attrs[:notable], content: attrs[:content]) do |n|
    n.pinned = attrs[:pinned] || false
  end
end

puts "  Created #{Note.count} notes"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
puts ""
puts "Seeding complete!"
puts "  Publishers:       #{Publisher.count}"
puts "  Agents:           #{Agent.count}"
puts "  Authors:          #{Author.count}"
puts "  Books:            #{Book.count}"
puts "  Deals:            #{Deal.count}"
puts "  Representations:  #{Representation.count}"
puts "  Prospects:        #{Prospect.count}"
puts "  Notes:            #{Note.count}"
puts "  Activities:       #{Activity.count} (auto-generated)"
