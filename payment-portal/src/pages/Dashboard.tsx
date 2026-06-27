import { useState, useEffect } from 'react';
import { type User, signOut } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from '../lib/firebase';
import { Check, ShieldCheck, Zap, LogOut, LayoutDashboard, Settings, User as UserIcon, CreditCard, Box } from 'lucide-react';

export default function Dashboard({ user }: { user: User }) {
  const [isPro, setIsPro] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkProStatus();
  }, [user]);

  const checkProStatus = async () => {
    try {
      const docRef = doc(db, 'anon_supporters', user.uid);
      const docSnap = await getDoc(docRef);
      
      if (docSnap.exists() && docSnap.data().is_pro === true) {
        setIsPro(true);
      }
    } catch (e) {
      console.error("Dashboard Load Error:", e);
    } finally {
      setLoading(false);
    }
  };

  const handleCheckout = () => {
    const options = {
      key: import.meta.env.VITE_RAZORPAY_KEY_ID || 'rzp_live_SZ4TAcERN4giIj',
      amount: 17900,
      currency: 'INR',
      name: 'SupaMobile Pro',
      description: 'Unlock Pro Features',
      prefill: { email: user.email },
      notes: { anon_id: user.uid },
      theme: { color: '#3ECF8E' },
      handler: function (_response: any) {
        alert('Payment successful! Your account is being upgraded via Firebase Cloud Functions.');
        setTimeout(checkProStatus, 3000);
      }
    };
    
    // @ts-ignore
    const rzp = new window.Razorpay(options);
    rzp.open();
  };

  const handleLogout = () => {
    signOut(auth);
  };

  if (loading) {
    return <div className="main-content"><p className="text-secondary">Loading dashboard...</p></div>;
  }

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--bg-base)', display: 'flex', flexDirection: 'column' }}>
      {/* Navbar */}
      <header style={{ borderBottom: '1px solid var(--border)', backgroundColor: 'var(--bg-surface)' }}>
        <div style={{ maxWidth: '1024px', margin: '0 auto', padding: '16px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <Box className="text-brand" size={24} />
            <h1 style={{ fontSize: '16px', margin: 0, fontWeight: 600 }}>SupaMobile Workspace</h1>
            <span style={{ padding: '4px 8px', borderRadius: '16px', backgroundColor: isPro ? 'rgba(62, 207, 142, 0.1)' : 'rgba(255, 255, 255, 0.05)', color: isPro ? 'var(--brand)' : 'var(--text-secondary)', fontSize: '12px', fontWeight: 500 }}>
              {isPro ? 'Pro Member' : 'Free Tier'}
            </span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '24px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-secondary)' }}>
              <UserIcon size={16} />
              <span style={{ fontSize: '14px' }}>{user.email}</span>
            </div>
            <button onClick={handleLogout} className="btn btn-secondary" style={{ padding: '8px 16px', height: 'auto', fontSize: '14px' }}>
              <LogOut size={14} />
              Logout
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main style={{ flex: 1, maxWidth: '1024px', margin: '0 auto', width: '100%', padding: '48px 24px' }}>
        <div style={{ display: 'grid', gridTemplateColumns: '250px 1fr', gap: '48px' }}>
          
          {/* Sidebar */}
          <aside style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <div style={{ padding: '8px 12px', borderRadius: '8px', backgroundColor: 'var(--bg-surface)', color: 'white', display: 'flex', alignItems: 'center', gap: '12px', fontWeight: 500 }}>
              <LayoutDashboard size={18} /> Overview
            </div>
            <div style={{ padding: '8px 12px', borderRadius: '8px', color: 'var(--text-secondary)', display: 'flex', alignItems: 'center', gap: '12px' }}>
              <CreditCard size={18} /> Billing
            </div>
            <div style={{ padding: '8px 12px', borderRadius: '8px', color: 'var(--text-secondary)', display: 'flex', alignItems: 'center', gap: '12px' }}>
              <Settings size={18} /> Settings
            </div>
          </aside>

          {/* Content */}
          <div>
            <h2 style={{ fontSize: '24px', margin: '0 0 24px 0' }}>Overview</h2>
            
            <div className="card" style={{ marginBottom: '24px', padding: '32px' }}>
              <h3 style={{ margin: '0 0 16px 0', fontSize: '18px' }}>Subscription Plan</h3>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '8px' }}>
                    <span style={{ fontSize: '24px', fontWeight: 600 }}>{isPro ? 'Pro' : 'Free'}</span>
                    {isPro && <ShieldCheck className="text-brand" size={24} />}
                  </div>
                  <p className="text-secondary" style={{ margin: 0 }}>
                    {isPro ? 'You have full access to all premium features on all your devices.' : 'Upgrade to Pro to unlock advanced analytics, secrets, and more.'}
                  </p>
                </div>
                {!isPro && (
                  <button onClick={handleCheckout} className="btn btn-primary" style={{ padding: '0 24px', height: '40px' }}>
                    <Zap size={16} /> Upgrade
                  </button>
                )}
              </div>
            </div>

            <div className="card" style={{ padding: '32px' }}>
              <h3 style={{ margin: '0 0 24px 0', fontSize: '18px' }}>Features & Usage</h3>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '16px', borderBottom: '1px solid var(--border)' }}>
                  <div>
                    <div style={{ fontWeight: 500, marginBottom: '4px' }}>Advanced Database Insights</div>
                    <div className="text-secondary" style={{ fontSize: '14px' }}>Monitor performance and query metrics.</div>
                  </div>
                  {isPro ? <Check className="text-brand" size={20} /> : <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Requires Pro</div>}
                </div>
                
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '16px', borderBottom: '1px solid var(--border)' }}>
                  <div>
                    <div style={{ fontWeight: 500, marginBottom: '4px' }}>Edge Function Secrets</div>
                    <div className="text-secondary" style={{ fontSize: '14px' }}>Manage env vars securely from your phone.</div>
                  </div>
                  {isPro ? <Check className="text-brand" size={20} /> : <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Requires Pro</div>}
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div>
                    <div style={{ fontWeight: 500, marginBottom: '4px' }}>30-Day Audit Logs</div>
                    <div className="text-secondary" style={{ fontSize: '14px' }}>Extended history for project activities.</div>
                  </div>
                  {isPro ? <Check className="text-brand" size={20} /> : <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Requires Pro</div>}
                </div>
              </div>
            </div>

          </div>
        </div>
      </main>
    </div>
  );
}
