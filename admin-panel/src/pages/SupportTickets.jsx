import React, { useState, useEffect } from 'react';
import api from '../api';

const SupportTickets = () => {
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [resolvingId, setResolvingId] = useState(null);
  const [adminResponse, setAdminResponse] = useState('');

  const fetchTickets = async () => {
    try {
      const response = await api.get('/support');
      setTickets(response.data);
    } catch (error) {
      console.error('Failed to fetch tickets:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTickets();
  }, []);

  const handleResolve = async (id) => {
    if (!adminResponse.trim()) {
      alert("Please enter a resolution message before resolving.");
      return;
    }
    
    try {
      await api.put(`/support/${id}/resolve`, { adminResponse });
      setResolvingId(null);
      setAdminResponse('');
      fetchTickets();
    } catch (error) {
      console.error('Failed to resolve ticket:', error);
      alert('Failed to resolve ticket.');
    }
  };

  if (loading) return <div className="loader-container"><div className="loader"></div></div>;

  return (
    <div>
      <h1 style={{ marginBottom: '2rem' }}>Help & Support Tickets</h1>
      <div className="table-container glass-panel">
        <div className="table-header">
          <h2>Technical Issues ({tickets.length})</h2>
        </div>
        <div style={{ overflowX: 'auto' }}>
          <table>
            <thead>
              <tr>
                <th>Date</th>
                <th>User</th>
                <th>Subject</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {tickets.map((ticket) => (
                <React.Fragment key={ticket._id}>
                  <tr>
                    <td>{new Date(ticket.createdAt).toLocaleDateString()}</td>
                    <td>
                      {ticket.user?.name || 'Unknown'} 
                      <br/><small style={{color:'var(--text-secondary)'}}>{ticket.user?.role}</small>
                    </td>
                    <td>
                      <strong>{ticket.subject}</strong>
                      <p style={{ margin: 0, fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
                        {ticket.message}
                      </p>
                      {ticket.adminResponse && (
                        <div style={{ marginTop: '0.5rem', padding: '0.5rem', background: 'rgba(16,185,129,0.1)', borderRadius: '0.5rem', fontSize: '0.875rem' }}>
                          <strong>Admin Reply: </strong> {ticket.adminResponse}
                        </div>
                      )}
                    </td>
                    <td>
                      <span className={`badge ${ticket.status === 'Open' ? 'badge-warning' : 'badge-success'}`}>
                        {ticket.status}
                      </span>
                    </td>
                    <td>
                      {ticket.status === 'Open' && resolvingId !== ticket._id && (
                        <button 
                          className="btn btn-primary" 
                          onClick={() => setResolvingId(ticket._id)}
                          style={{ padding: '0.5rem 1rem' }}
                        >
                          Resolve
                        </button>
                      )}
                      {ticket.status === 'Resolved' && (
                        <span style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Resolved</span>
                      )}
                    </td>
                  </tr>
                  {resolvingId === ticket._id && (
                    <tr>
                      <td colSpan="5" style={{ background: 'rgba(79, 70, 229, 0.05)' }}>
                        <div style={{ display: 'flex', gap: '1rem', alignItems: 'flex-start' }}>
                          <textarea
                            value={adminResponse}
                            onChange={(e) => setAdminResponse(e.target.value)}
                            placeholder="Type resolution message here..."
                            style={{ flex: 1, padding: '0.75rem', borderRadius: '0.5rem', border: '1px solid var(--border-color)', outline: 'none', resize: 'vertical', minHeight: '80px' }}
                          ></textarea>
                          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                            <button className="btn btn-primary" onClick={() => handleResolve(ticket._id)}>Submit Resolution</button>
                            <button className="btn" onClick={() => setResolvingId(null)} style={{ background: '#e5e7eb' }}>Cancel</button>
                          </div>
                        </div>
                      </td>
                    </tr>
                  )}
                </React.Fragment>
              ))}
              {tickets.length === 0 && (
                <tr>
                  <td colSpan="5" style={{ textAlign: 'center', padding: '2rem' }}>No support tickets found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default SupportTickets;
