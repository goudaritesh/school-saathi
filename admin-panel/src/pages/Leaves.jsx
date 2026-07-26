import React, { useState, useEffect } from 'react';
import api from '../api';

const Leaves = () => {
  const [leaves, setLeaves] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchLeaves = async () => {
      try {
        const response = await api.get('/admin/leaves');
        setLeaves(response.data);
      } catch (error) {
        console.error('Failed to fetch leaves:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchLeaves();
  }, []);

  if (loading) return <div className="loader-container"><div className="loader"></div></div>;

  return (
    <div>
      <h1 style={{ marginBottom: '2rem' }}>Leave Requests</h1>
      <div className="table-container glass-panel">
        <div className="table-header">
          <h2>All Leaves ({leaves.length})</h2>
        </div>
        <div style={{ overflowX: 'auto' }}>
          <table>
            <thead>
              <tr>
                <th>Student</th>
                <th>From (Parent)</th>
                <th>To (Driver)</th>
                <th>Dates</th>
                <th>Reason</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {leaves.map((leave) => (
                <tr key={leave._id}>
                  <td><strong>{leave.studentName}</strong></td>
                  <td>{leave.parent?.name || 'Unknown'}</td>
                  <td>{leave.driver?.name || 'Unknown'}</td>
                  <td>
                    {new Date(leave.startDate).toLocaleDateString()} - <br/>
                    {new Date(leave.endDate).toLocaleDateString()}
                  </td>
                  <td>{leave.reason}</td>
                  <td>
                    <span className={`badge ${
                      leave.status === 'pending' ? 'badge-warning' : 
                      leave.status === 'approved' ? 'badge-success' : 'badge-danger'
                    }`}>
                      {leave.status}
                    </span>
                  </td>
                </tr>
              ))}
              {leaves.length === 0 && (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '2rem' }}>No leave requests found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Leaves;
