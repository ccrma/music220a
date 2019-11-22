module.exports = {
  "env": {
    "es6": true,
  },
  "extends": "google",
  "parserOptions": {
    "ecmaVersion": 2018,
    "sourceType": "module"
  },
  "overrides": [{
    "files": [
      '01-orientation/**',
      '02-waa-basics/**',
      '03-additive/**',
      '04-subtractive/**',
      '05-modulation/**',
      '06-sample-and-synthe/**',
      '07-time-and-space/**',
      '08-user-interaction/**',
      '09-nonlinear-effects/**',
    ],
    "rules": {
      "require-jsdoc": 0
    }
  }]
};