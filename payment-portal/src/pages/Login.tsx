import { useState } from 'react';
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  sendPasswordResetEmail,
  sendEmailVerification
} from 'firebase/auth';
import { auth } from '../lib/firebase';
import { Mail, Key, ArrowRight, Loader2, CheckCircle2 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const [loading, setLoading] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [mode, setMode] = useState<'login' | 'signup' | 'forgot' | 'verify'>('login');
  const [errorMsg, setErrorMsg] = useState('');
  const [successMsg, setSuccessMsg] = useState('');
  const navigate = useNavigate();

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg('');
    setSuccessMsg('');

    try {
      if (mode === 'login') {
        const userCred = await signInWithEmailAndPassword(auth, email, password);
        if (!userCred.user.emailVerified) {
          setMode('verify');
          setLoading(false);
          return;
        }
        navigate('/dashboard');
      } else if (mode === 'signup') {
        const userCred = await createUserWithEmailAndPassword(auth, email, password);
        await sendEmailVerification(userCred.user);
        setMode('verify');
      } else if (mode === 'forgot') {
        await sendPasswordResetEmail(auth, email);
        setSuccessMsg('Password reset link sent to your email.');
        setMode('login');
      }
    } catch (error: any) {
      setErrorMsg(error.message);
    } finally {
      setLoading(false);
    }
  };

  const resendVerification = async () => {
    if (auth.currentUser) {
      await sendEmailVerification(auth.currentUser);
      setSuccessMsg('Verification email resent.');
    }
  };

  if (mode === 'verify') {
    return (
      <div className="main-content">
        <div className="card text-center" style={{ maxWidth: '400px' }}>
          <div style={{ display: 'inline-flex', padding: '16px', borderRadius: '16px', backgroundColor: 'rgba(62, 207, 142, 0.1)', marginBottom: '16px' }}>
            <CheckCircle2 className="text-brand" size={32} />
          </div>
          <h2>Verify your email</h2>
          <p className="text-secondary mt-8">We sent a verification link to <strong>{email}</strong>. Please click it to continue.</p>
          
          {successMsg && <div className="text-brand" style={{ marginTop: '16px', fontSize: '14px' }}>{successMsg}</div>}
          
          <button onClick={resendVerification} className="btn btn-secondary mt-32" style={{ width: '100%' }}>
            Resend Email
          </button>
          <button onClick={() => { auth.signOut(); setMode('login'); }} className="btn mt-16" style={{ width: '100%', background: 'transparent', color: 'var(--text-secondary)' }}>
            Back to Sign In
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="main-content">
      <div className="card" style={{ maxWidth: '400px', width: '100%' }}>
        <div className="text-center mb-32">
          <div style={{ display: 'inline-flex', padding: '16px', borderRadius: '16px', backgroundColor: 'rgba(62, 207, 142, 0.1)', marginBottom: '16px' }}>
            {mode === 'forgot' ? <Mail className="text-brand" size={32} /> : <Key className="text-brand" size={32} />}
          </div>
          <h2>{mode === 'login' ? 'Sign In' : mode === 'signup' ? 'Create Account' : 'Reset Password'}</h2>
          <p className="text-secondary mt-8">
            {mode === 'login' ? 'Welcome back to SupaMobile.' : mode === 'signup' ? 'Start managing your databases on the go.' : 'Enter your email to receive a reset link.'}
          </p>
        </div>

        {errorMsg && <div className="error-msg">{errorMsg}</div>}
        {successMsg && <div className="success-msg" style={{ padding: '12px', borderRadius: '8px', backgroundColor: 'rgba(62, 207, 142, 0.1)', color: 'var(--brand)', marginBottom: '24px', fontSize: '14px' }}>{successMsg}</div>}

        <form onSubmit={handleAuth}>
          <div className="input-group">
            <label className="input-label" htmlFor="email">Email</label>
            <div style={{ position: 'relative' }}>
              <Mail style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)' }} size={20} className="text-secondary" />
              <input
                id="email"
                type="email"
                required
                className="input-field"
                style={{ paddingLeft: '48px' }}
                placeholder="you@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
          </div>

          {mode !== 'forgot' && (
            <div className="input-group">
              <label className="input-label" htmlFor="password">Password</label>
              <div style={{ position: 'relative' }}>
                <Key style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)' }} size={20} className="text-secondary" />
                <input
                  id="password"
                  type="password"
                  required
                  className="input-field"
                  style={{ paddingLeft: '48px' }}
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
              </div>
            </div>
          )}

          <button type="submit" className="btn btn-primary mt-32" style={{ width: '100%' }} disabled={loading}>
            {loading ? <Loader2 className="animate-spin" /> : (
              <>
                {mode === 'login' ? 'Sign In' : mode === 'signup' ? 'Sign Up' : 'Send Reset Link'}
                <ArrowRight size={18} />
              </>
            )}
          </button>
          
          <div style={{ textAlign: 'center', marginTop: '24px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {mode === 'login' ? (
              <>
                <button type="button" onClick={() => setMode('signup')} style={{ background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer', fontSize: '0.875rem' }}>
                  Don't have an account? <span style={{ color: 'var(--brand)' }}>Sign up</span>
                </button>
                <button type="button" onClick={() => setMode('forgot')} style={{ background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer', fontSize: '0.875rem' }}>
                  Forgot your password?
                </button>
              </>
            ) : mode === 'signup' ? (
              <button type="button" onClick={() => setMode('login')} style={{ background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer', fontSize: '0.875rem' }}>
                Already have an account? <span style={{ color: 'var(--brand)' }}>Sign in</span>
              </button>
            ) : (
              <button type="button" onClick={() => setMode('login')} style={{ background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer', fontSize: '0.875rem' }}>
                Back to sign in
              </button>
            )}
          </div>
        </form>
      </div>
    </div>
  );
}
