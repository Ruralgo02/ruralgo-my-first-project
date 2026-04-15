const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

// IMPORTANT: rotate this key in Paystack dashboard after this
const PAYSTACK_SECRET_KEY = 'sk_test_5797d6d351f30c94f1b618665b182f10d3d778fb';

const paystack = axios.create({
  baseURL: 'https://api.paystack.co',
  headers: {
    Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
    'Content-Type': 'application/json',
  },
  timeout: 20000,
});

app.get('/', (req, res) => {
  res.status(200).send('RuralGo Paystack server is running ✅');
});

app.post('/paystack/initialize', async (req, res) => {
  try {
    const { email, amount, reference } = req.body;

    if (!email || !amount || !reference) {
      return res.status(400).json({
        status: false,
        message: 'email, amount and reference are required',
      });
    }

    const response = await paystack.post('/transaction/initialize', {
      email,
      amount,
      reference,
    });

    return res.status(200).json(response.data);
  } catch (error) {
    console.log('INIT ERROR FULL:', error.response?.data || error.message);

    return res.status(500).json({
      status: false,
      message:
        error.response?.data?.message || error.message || 'Server error',
    });
  }
});

app.post('/paystack/assign-dva', async (req, res) => {
  try {
    const { email, first_name, last_name, phone } = req.body;

    if (!email || !first_name || !last_name || !phone) {
      return res.status(400).json({
        status: false,
        message: 'email, first_name, last_name and phone are required',
      });
    }

    const response = await paystack.post('/dedicated_account/assign', {
      email,
      first_name,
      last_name,
      phone,
      preferred_bank: 'wema-bank',
    });

    return res.status(200).json(response.data);
  } catch (error) {
    console.log('DVA ERROR FULL:', error.response?.data || error.message);

    return res.status(500).json({
      status: false,
      message:
        error.response?.data?.message || error.message || 'Server error',
    });
  }
});

app.use((err, req, res, next) => {
  console.log('UNCAUGHT SERVER ERROR:', err);
  return res.status(500).json({
    status: false,
    message: err.message || 'Unexpected server error',
  });
});

app.listen(3000, '0.0.0.0', () => {
  console.log('Paystack server running on http://0.0.0.0:3000');
});