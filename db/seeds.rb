users = User.create([
  { name: 'John Doe', email_address: 'john@company.com', password: '123456' },
  { name: 'Jane Smith', email_address: 'jane@company.com', password: '123456' },
  { name: 'Bob Johnson', email_address: 'bob@company.com', password: '123456' },
  { name: 'Emily Brown', email_address: 'emily@company.com', password: '123456' },
  { name: 'Michael Wilson', email_address: 'michael@company.com', password: '123456' }
])

# Create a company
Company.create(name: 'Taylor Inc.')

# Create employee_infos
EmployeeInfo.create([
  { user: users.first, company: Company.first, department: 'Engineering' },
  { user: users.second, company: Company.first, department: 'Marketing' },
  { user: users.third, company: Company.first, department: 'Sales' },
  { user: users.fourth, company: Company.first, department: 'HR' },
  { user: users.fifth, company: Company.first, department: 'Finance' }
])

# Create profile
Profile.create([
 { external_link: 'https://johnsprofile.com', date_of_birth: '1980-01-01',
   employee_info: EmployeeInfo.find_by(user: users.first) },
 { external_link: 'https://janesprofile.com', date_of_birth: '1985-05-15',
   employee_info: EmployeeInfo.find_by(user: users.second) },
 { external_link: 'https://bobsprofile.com', date_of_birth: '1990-07-30',
   employee_info: EmployeeInfo.find_by(user: users.third) },
 { external_link: 'https://emilysprofile.com', date_of_birth: '1992-11-20',
   employee_info: EmployeeInfo.find_by(user: users.fourth) },
 { external_link: 'https://michaelsprofile.com', date_of_birth: '1988-03-10',
   employee_info: EmployeeInfo.find_by(user: users.fifth) }
])

# Create cards
Card.create([
  { user: users.first, card_number: '1548' },
  { user: users.second, card_number: '7370' },
  { user: users.third, card_number: '6512' },
  { user: users.first, card_number: '8912' },
  { user: users.second, card_number: '4567' }
])

# Create ring_cards
RingCard.create([
  { user: users.first, ring_number: '1234' },
  { user: users.third, ring_number: '5678' }
])

categories = Category.create([ { name: 'Clothing' }, { name: 'Electronics' } ])

clothing_category = Category.find_by(name: 'Clothing')
electronics_category = Category.find_by(name: 'Electronics')

Product.create([
 { name: 'Running Shoes', price: 50.00, category: clothing_category },
 { name: 'T-Shirt', price: 20.00, category: clothing_category },
 { name: 'Smartphone', price: 500.00, category: electronics_category },
 { name: 'Laptop', price: 1000.00, category: electronics_category }
])

# Seed data for Actresses
actresses = Actress.create([
 { id: 1, name: "多部未華子" },
 { id: 2, name: "佐津川愛美" },
 { id: 3, name: "新垣結衣" },
 { id: 4, name: "堀北真希" },
 { id: 5, name: "吉高由里子" },
 { id: 6, name: "悠城早矢" }
])

# Seed data for Movies
movies = Movie.create([
  { id: 1, actress_id: 2, title: "蝉しぐれ", year: 2005 },
  { id: 2, actress_id: 1, title: "夜のピクニック", year: 2006 },
  { id: 3, actress_id: 4, title: "ALWAYS 三丁目の夕日", year: 2005 },
  { id: 4, actress_id: 2, title: "忍道-SHINOBIDO-", year: 2012 },
  { id: 5, actress_id: 2, title: "貞子vs伽椰子", year: 2016 },
  { id: 6, actress_id: 4, title: "県庁おもてなし課", year: 2013 },
  { id: 7, actress_id: 5, title: "真夏の方程式", year: 2013 }
])

# Creating 10 seed posts
Post.create([
  { title: 'First Post', user_id: users[0].id, published: true, created_at: Time.now, updated_at: Time.now },
  { title: 'Tech Trends', user_id: users[1].id, published: false, created_at: Time.now, updated_at: Time.now },
  { title: 'Ruby Tips', user_id: users[2].id, published: true, created_at: Time.now, updated_at: Time.now },
  { title: 'Rails Guide', user_id: users[3].id, published: true, created_at: Time.now, updated_at: Time.now },
  { title: 'Coding Journey', user_id: users[4].id, published: false, created_at: Time.now, updated_at: Time.now },
  { title: 'Web Dev Basics', user_id: users[0].id, published: true, created_at: Time.now, updated_at: Time.now },
  { title: 'API Design', user_id: users[1].id, published: true, created_at: Time.now, updated_at: Time.now },
  { title: 'Database Tips', user_id: users[2].id, published: false, created_at: Time.now, updated_at: Time.now },
  { title: 'Frontend Fun', user_id: users[3].id, published: true, created_at: Time.now, updated_at: Time.now },
  { title: 'Backend Basics', user_id: users[4].id, published: true, created_at: Time.now, updated_at: Time.now }
])