import { Link } from 'react-router-dom';
import { Database, Key, Shield, ArrowRight } from 'lucide-react';

export default function Landing() {
  return (
    <div className="container">
      {/* Navigation */}
      <nav className="navbar">
        <Link to="/" className="logo">
          <div style={{ width: '24px', height: '24px', backgroundColor: 'var(--brand-primary)', borderRadius: '6px' }}></div>
          SupaMobile
        </Link>
        <div className="nav-links">
          <Link to="/login" className="btn btn-secondary" style={{ height: '36px', padding: '0 var(--space-16)', fontSize: '0.875rem' }}>
            Sign In
          </Link>
          <Link to="/login" className="btn btn-primary" style={{ height: '36px', padding: '0 var(--space-16)', fontSize: '0.875rem' }}>
            Get Pro
          </Link>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="hero">
        <div style={{ display: 'inline-block', padding: '4px 12px', borderRadius: '100px', backgroundColor: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', marginBottom: 'var(--space-24)', fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
          Now with RevenueCat integration
        </div>
        <h1 style={{ maxWidth: '800px', margin: '0 auto var(--space-24)' }}>
          Manage your Supabase projects from your pocket.
        </h1>
        <p>
          Access your database, handle authentication, and run edge functions directly from your mobile device. Ship faster with less back-and-forth.
        </p>
        <div style={{ display: 'flex', gap: 'var(--space-16)', justifyContent: 'center', marginTop: 'var(--space-32)' }}>
          <Link to="/login" className="btn btn-primary">
            Get started
            <ArrowRight size={20} />
          </Link>
        </div>
      </section>

      {/* Features Grid */}
      <section style={{ padding: 'var(--space-64) 0' }}>
        <h2 style={{ textAlign: 'center', marginBottom: 'var(--space-16)' }}>Pro features that work for you.</h2>
        <p style={{ textAlign: 'center', margin: '0 auto', marginBottom: 'var(--space-48)' }}>Unlock the full potential of SupaMobile with our one-time Pro upgrade.</p>
        
        <div className="grid-3">
          <div className="card">
            <Database className="text-brand" size={24} style={{ marginBottom: 'var(--space-16)' }} />
            <h3>Database insights</h3>
            <p style={{ margin: 0 }}>View query performance, active connections, and table sizes in real-time. Catch slow queries before they affect your users.</p>
          </div>
          
          <div className="card">
            <Key className="text-brand" size={24} style={{ marginBottom: 'var(--space-16)' }} />
            <h3>Secrets management</h3>
            <p style={{ margin: 0 }}>Securely add, edit, or delete Edge Function secrets directly from your phone. No need to open your laptop for quick fixes.</p>
          </div>
          
          <div className="card">
            <Shield className="text-brand" size={24} style={{ marginBottom: 'var(--space-16)' }} />
            <h3>30 days audit logs</h3>
            <p style={{ margin: 0 }}>Track every API request and database change with an extended 30-day retention period. Perfect for debugging production issues.</p>
          </div>
        </div>
      </section>

      {/* Footer CTA */}
      <section style={{ padding: 'var(--space-96) 0', textAlign: 'center', borderTop: '1px solid var(--border-color)' }}>
        <h2 style={{ marginBottom: 'var(--space-24)' }}>Ready to upgrade?</h2>
        <Link to="/login" className="btn btn-primary">
          View pricing
        </Link>
      </section>
    </div>
  );
}
