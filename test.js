const assert = require('assert');
const startOfDay = new Date();
startOfDay.setHours(0, 0, 0, 0);
console.log("startOfDay:", startOfDay.toISOString());
console.log("now:", new Date().toISOString());
