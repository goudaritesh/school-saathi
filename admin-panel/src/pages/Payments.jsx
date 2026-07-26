import React, { useState, useEffect } from 'react';
import api from '../api';

const Payments = () => {
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchPayments = async () => {
      try {
        const response = await api.get('/admin/reports/fees');
        setPayments(response.data);
      } catch (error) {
        console.error('Failed to fetch payments:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchPayments();
  }, []);

  if (loading) return <div className="loader-container"><div className="loader"></div></div>;

  return (
    <div>
      <h1 style={{ marginBottom: '2rem' }}>Payment Details</h1>
      <div className="table-container glass-panel">
        <div className="table-header">
          <h2>All Transactions ({payments.length})</h2>
        </div>
        <div style={{ overflowX: 'auto' }}>
          <table>
            <thead>
              <tr>
                <th>Date</th>
                <th>Parent</th>
                <th>Driver</th>
                <th>Month</th>
                <th>Amount</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {payments.map((payment) => (
                <tr key={payment._id}>
                  <td>{new Date(payment.createdAt).toLocaleDateString()}</td>
                  <td>{payment.parent_profile?.user?.name || 'Unknown'}</td>
                  <td>{payment.driver?.name || 'Unknown'}</td>
                  <td>{payment.month}</td>
                  <td style={{ fontWeight: 600 }}>₹{payment.amount}</td>
                  <td>
                    <span className={`badge ${payment.status === 'Paid' ? 'badge-success' : 'badge-warning'}`}>
                      {payment.status}
                    </span>
                  </td>
                </tr>
              ))}
              {payments.length === 0 && (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '2rem' }}>No payment records found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Payments;
