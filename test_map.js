const mongoose = require('mongoose');

const id1 = new mongoose.Types.ObjectId();
const id2 = new mongoose.Types.ObjectId();

const studentsData = [
  { _id: id1, name: 'Alice' },
  { _id: id2, name: 'Bob' }
];

const attendances = [
  { parent_profile: id1, status: 'Picked Up' }, // Simulating non-lean mongoose doc where parent_profile is ObjectId
];

const students = studentsData.map(student => {
    const studentAttendance = attendances.find(a => a.parent_profile.toString() === student._id.toString());
    return {
        ...student,
        today_attendance: studentAttendance ? studentAttendance.status : 'Pending'
    };
});

console.log(students);
