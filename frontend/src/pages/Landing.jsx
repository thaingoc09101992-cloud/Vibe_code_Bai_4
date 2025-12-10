import { useState } from 'react';
import { Link } from 'react-router-dom';
import { BookOpen, Search, Users, ArrowRight, BookMarked, Clock, Award } from 'lucide-react';

function Landing() {
  const [searchQuery, setSearchQuery] = useState('');

  const features = [
    {
      icon: <BookOpen className="w-6 h-6" />,
      title: 'Vast Collection',
      description: 'Access thousands of books across fiction, technology, science, and more'
    },
    {
      icon: <Clock className="w-6 h-6" />,
      title: 'Easy Borrowing',
      description: 'Borrow books online and manage your reading schedule effortlessly'
    },
    {
      icon: <Users className="w-6 h-6" />,
      title: 'Community',
      description: 'Join a community of readers and discover new perspectives'
    },
    {
      icon: <Award className="w-6 h-6" />,
      title: 'Curated Lists',
      description: 'Explore handpicked collections and staff recommendations'
    }
  ];

  const popularBooks = [
    {
      title: 'Clean Code',
      author: 'Robert C. Martin',
      category: 'Technology',
      available: 5
    },
    {
      title: 'Atomic Habits',
      author: 'James Clear',
      category: 'Self-Help',
      available: 6
    },
    {
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      category: 'Non-Fiction',
      available: 5
    },
    {
      title: '1984',
      author: 'George Orwell',
      category: 'Fiction',
      available: 3
    }
  ];

  const stats = [
    { value: '15+', label: 'Books Available' },
    { value: '7', label: 'Categories' },
    { value: '24/7', label: 'Online Access' },
    { value: '100%', label: 'Free to Join' }
  ];

  return (
    <div className="min-h-screen">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 glass border-b border-paper-200">
        <div className="container-custom py-4">
          <div className="flex items-center justify-between">
            <Link to="/" className="flex items-center space-x-2">
              <BookMarked className="w-8 h-8 text-ink-800" />
              <h1 className="text-2xl font-bold text-ink-900">LibraryHub</h1>
            </Link>
            <div className="hidden md:flex items-center space-x-8">
              <a href="#" className="text-ink-600 hover:text-ink-900 transition-colors">Browse Books</a>
              <a href="#" className="text-ink-600 hover:text-ink-900 transition-colors">Categories</a>
              <a href="#" className="text-ink-600 hover:text-ink-900 transition-colors">About</a>
            </div>
            <div className="flex items-center space-x-4">
              <Link to="/login" className="btn-outline text-sm">Sign In</Link>
              <Link to="/register" className="btn-primary text-sm">Get Started</Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-4">
        <div className="container-custom">
          <div className="max-w-4xl mx-auto text-center animate-fade-in">
            <h2 className="text-5xl md:text-6xl lg:text-7xl font-bold text-ink-900 mb-6 text-balance">
              Your Digital Library,
              <span className="block text-wood-600 mt-2">Reimagined</span>
            </h2>
            <p className="text-xl md:text-2xl text-ink-600 mb-12 text-balance max-w-2xl mx-auto">
              Discover, borrow, and enjoy books from our curated collection.
              A modern library experience at your fingertips.
            </p>

            {/* Search Bar */}
            <div className="max-w-2xl mx-auto mb-12 animate-slide-up">
              <div className="relative">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-ink-400" />
                <input
                  type="text"
                  placeholder="Search for books, authors, or topics..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="input pl-12 pr-32 py-4 text-lg shadow-soft-md"
                />
                <button className="absolute right-2 top-1/2 -translate-y-1/2 btn-primary">
                  Search
                </button>
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mt-16">
              {stats.map((stat, index) => (
                <div key={index} className="card p-6 text-center">
                  <div className="text-3xl md:text-4xl font-bold text-wood-600 mb-2">{stat.value}</div>
                  <div className="text-sm text-ink-600">{stat.label}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-white">
        <div className="container-custom">
          <div className="text-center mb-16">
            <h3 className="text-4xl md:text-5xl font-bold text-ink-900 mb-4">Why Choose LibraryHub?</h3>
            <p className="text-xl text-ink-600 max-w-2xl mx-auto">
              Experience the perfect blend of traditional library warmth and modern convenience
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature, index) => (
              <div
                key={index}
                className="card-hover p-8 text-center group"
                style={{ animationDelay: `${index * 100}ms` }}
              >
                <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-wood-100 text-wood-700 mb-6 group-hover:bg-wood-600 group-hover:text-white transition-colors duration-300">
                  {feature.icon}
                </div>
                <h4 className="text-xl font-semibold text-ink-900 mb-3">{feature.title}</h4>
                <p className="text-ink-600">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Popular Books Section */}
      <section className="py-20 bg-gradient-to-b from-paper-50 to-white">
        <div className="container-custom">
          <div className="flex items-center justify-between mb-12">
            <div>
              <h3 className="text-4xl font-bold text-ink-900 mb-2">Popular Books</h3>
              <p className="text-xl text-ink-600">Most borrowed titles this month</p>
            </div>
            <button className="btn-outline group">
              View All
              <ArrowRight className="inline-block ml-2 w-4 h-4 group-hover:translate-x-1 transition-transform" />
            </button>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {popularBooks.map((book, index) => (
              <div key={index} className="card-hover p-6 group">
                <div className="w-full h-48 bg-gradient-to-br from-wood-100 to-wood-200 rounded-xl mb-4 flex items-center justify-center">
                  <BookOpen className="w-16 h-16 text-wood-500" />
                </div>
                <div className="mb-2">
                  <span className="inline-block px-3 py-1 bg-accent-100 text-accent-700 text-xs font-medium rounded-full">
                    {book.category}
                  </span>
                </div>
                <h4 className="text-lg font-semibold text-ink-900 mb-1 group-hover:text-wood-600 transition-colors">
                  {book.title}
                </h4>
                <p className="text-ink-600 text-sm mb-4">{book.author}</p>
                <div className="flex items-center justify-between pt-4 border-t border-paper-200">
                  <span className="text-sm text-ink-500">{book.available} available</span>
                  <button className="text-sm text-wood-600 font-medium hover:text-wood-700 transition-colors">
                    Borrow →
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-ink-900 text-white">
        <div className="container-custom">
          <div className="max-w-3xl mx-auto text-center">
            <h3 className="text-4xl md:text-5xl font-bold mb-6">Ready to Start Reading?</h3>
            <p className="text-xl text-ink-300 mb-10">
              Join our community of readers today. Sign up for free and get instant access to our entire collection.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link to="/register" className="btn bg-white text-ink-900 hover:bg-paper-100 text-lg px-8 py-4">
                Create Account
              </Link>
              <button className="btn border-2 border-white text-white hover:bg-white hover:text-ink-900 text-lg px-8 py-4">
                Browse Books
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-ink-950 text-ink-300 py-12">
        <div className="container-custom">
          <div className="grid md:grid-cols-4 gap-8 mb-8">
            <div>
              <div className="flex items-center space-x-2 mb-4">
                <BookMarked className="w-6 h-6 text-white" />
                <span className="text-lg font-bold text-white">LibraryHub</span>
              </div>
              <p className="text-sm">
                Your modern digital library for discovering and borrowing books online.
              </p>
            </div>
            <div>
              <h5 className="text-white font-semibold mb-4">Quick Links</h5>
              <ul className="space-y-2 text-sm">
                <li><a href="#" className="hover:text-white transition-colors">Browse Books</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Categories</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Popular</a></li>
                <li><a href="#" className="hover:text-white transition-colors">New Arrivals</a></li>
              </ul>
            </div>
            <div>
              <h5 className="text-white font-semibold mb-4">Account</h5>
              <ul className="space-y-2 text-sm">
                <li><Link to="/login" className="hover:text-white transition-colors">Sign In</Link></li>
                <li><Link to="/register" className="hover:text-white transition-colors">Register</Link></li>
                <li><a href="#" className="hover:text-white transition-colors">My Books</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Settings</a></li>
              </ul>
            </div>
            <div>
              <h5 className="text-white font-semibold mb-4">Support</h5>
              <ul className="space-y-2 text-sm">
                <li><a href="#" className="hover:text-white transition-colors">Help Center</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Contact Us</a></li>
                <li><a href="#" className="hover:text-white transition-colors">FAQ</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Privacy Policy</a></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-ink-800 pt-8 text-center text-sm">
            <p>&copy; 2025 LibraryHub. All rights reserved. Built with care for book lovers.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default Landing;
