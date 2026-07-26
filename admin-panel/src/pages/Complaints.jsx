import React, { useState, useEffect } from 'react';
import api from '../api';

const Complaints = () => {
  const [complaints, setComplaints] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchComplaints = async () => {
      try {
        const response = await api.get('/admin/complaints');
        setComplaints(response.data);
      } catch (error) {
        console.error('Failed to fetch complaints:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchComplaints();
  }, []);

  if (loading) return <div className="loader-container"><div className="loader"></div></div>;

  return (
    <div>
      <h1 style={{ marginBottom: '2rem' }}>Complaints Tracker</h1>
      <div className="table-container glass-panel">
        <div className="table-header">
          <h2>All Complaints ({complaints.length})</h2>
        </div>
        <div style={{ overflowX: 'auto' }}>
          <table>
            <thead>
              <tr>
                <th>Date</th>
                <th>From (Parent)</th>
                <th>To (Driver)</th>
                <th>Subject</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {complaints.map((complaint) => (
                <tr key={complaint._id}>
                  <td>{new Date(complaint.createdAt).toLocaleDateString()}</td>
                  <td>
                    {complaint.parent?.name || 'Unknown'} 
                    <br/><small style={{color:'var(--text-secondary)'}}>{complaint.parent?.role}</small>
                  </td>
                  <td>
                    {complaint.driver?.name || 'Unknown'}
                    <br/><small style={{color:'var(--text-secondary)'}}>{complaint.driver?.role}</small>
                  </td>
                  <td>
                    <strong>{complaint.subject}</strong>
                    <p style={{ margin: 0, fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
                      {complaint.description.length > 50 ? complaint.description.substring(0, 50) + '...' : complaint.description}
                    </p>
                  </td>
                  <td>
                    <span className={`badge ${
                      complaint.status === 'open' ? 'badge-danger' : 
                      complaint.status === 'in-progress' ? 'badge-warning' : 'badge-success'
                    }`}>
                      {complaint.status}
                    </span>
                  </td>
                </tr>
              ))}
              {complaints.length === 0 && (
                <tr>
                  <td colSpan="5" style={{ textAlign: 'center', padding: '2rem' }}>No complaints found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Complaints;
