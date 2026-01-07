# 💳 Payment Method Demo Guide

## 📋 Complete Demo Flow

### Step 1: Add Payment Method (Setup)
1. **Login** as pet owner
2. Go to **Profile** tab (bottom navigation)
3. Tap **Payment Methods**
4. Tap **+ Add Card** (floating button)
5. Enter test card details:
   - Card Number: `4111 1111 1111 1111` (Visa)
   - Cardholder Name: `John Doe`
   - Expiry: `12/25`
   - CVV: `123`
   - ✓ Check "Set as default"
6. Tap **Add Card**
7. Card appears with blue gradient!

### Step 2: Book a Pet Sitter
1. Go to **Community** tab
2. Browse sitters or search
3. Tap on a sitter profile
4. Select dates (Check-in & Check-out)
5. Tap **Book Now**

### Step 3: Complete Booking with Payment
1. **Booking Modal** opens showing:
   - Sitter name & rate
   - Selected dates
   - Drop-off & Pick-up times
   - Select your pet
   - 💳 **Payment Method** (newly added!)
   
2. Review booking details
3. See **total amount** calculated
4. Tap **Pay & Book Now** button
5. Payment is processed using selected card
6. Booking confirmed! 🎉

### Step 4: View Booking
1. Go to **Home** tab
2. Scroll to **My Bookings** section
3. See your booking with:
   - Sitter info
   - Dates & times
   - Status: "Pending" → Waits for sitter to accept
   - Amount paid

### Step 5: Sitter Accepts (Optional)
1. Sitter logs in
2. Goes to Sitter Dashboard
3. Sees booking request
4. Taps **Accept**
5. Booking status → "Confirmed"

---

## 🧪 Test Card Numbers

| Card Type | Number | Result |
|-----------|--------|--------|
| Visa | `4111 1111 1111 1111` | ✅ Success |
| Mastercard | `5500 0000 0000 0004` | ✅ Success |
| Amex | `3400 0000 0000 009` | ✅ Success |

**Note:** For demo purposes, we're storing card info securely (last 4 digits only). In production, you'd use Stripe, PayPal, or similar payment gateway.

---

## 💡 Demo Talking Points

### 1. **Security**
   - "We only store the last 4 digits of your card"
   - "Full card details are encrypted"
   - "You can add multiple cards and set a default"

### 2. **User Experience**
   - "Smart card number formatting as you type"
   - "Auto-detects card type (Visa, Mastercard, Amex)"
   - "Beautiful credit card UI with gradients"

### 3. **Payment Flow**
   - "Seamless payment during booking"
   - "Clear price breakdown"
   - "Payment processed immediately"
   - "Booking confirmed instantly"

### 4. **Multi-Card Support**
   - "Add multiple payment methods"
   - "Set a default card"
   - "Switch between cards easily"
   - "Delete old cards anytime"

---

## 🎬 Demo Script

> **"Let me show you how pet owners pay for pet sitting services in Pawsure."**

1. **Setup** (30 seconds)
   - "First, I'll add a payment method to my account..."
   - Navigate: Profile → Payment Methods → Add Card
   - Enter test card details
   - "And it's added! Beautiful card display."

2. **Booking** (1 minute)
   - "Now let's book a pet sitter for my dog Max..."
   - Navigate: Community → Select Sitter → Book Now
   - "I select the dates, times, and my pet..."
   - "Here's the payment method section - it shows my default card"
   - "I can see the total amount: RM150 for 3 nights"
   - Tap "Pay & Book Now"

3. **Confirmation** (20 seconds)
   - "Payment successful! Booking confirmed."
   - "I can now see it in my Home tab under bookings"
   - "The sitter will receive a notification to accept"

4. **Additional Features** (30 seconds)
   - Go back to Payment Methods
   - "I can add more cards, set a different default, or delete old ones"
   - Show delete confirmation dialog

---

## 🔄 Database Records Created

When you complete a booking with payment:

### `bookings` table:
```
id: 1
owner_id: 1
sitter_id: 2
pet_id: 1
start_date: 2025-01-10
end_date: 2025-01-13
total_amount: 150.00
status: 'pending'
payment_method_id: 1  ← NEW!
```

### `payment_methods` table:
```
id: 1
userId: 1
cardType: 'visa'
lastFourDigits: '1111'
cardholderName: 'John Doe'
expiryMonth: '12'
expiryYear: '2025'
isDefault: true
```

---

## 🚀 Future Enhancements (Mention if asked)

1. **Real Payment Gateway Integration**
   - Stripe/PayPal integration
   - 3D Secure authentication
   - Real-time payment status

2. **Payment History**
   - View all transactions
   - Download receipts
   - Refund requests

3. **Saved Payment Methods**
   - Apple Pay / Google Pay
   - Bank account linking
   - Auto-pay for recurring bookings

---

## ⚠️ Important Notes

- **This is a demo**: We're simulating payment processing
- **Real production**: Would integrate with Stripe/PayPal
- **Security**: Never store full card numbers (PCI compliance)
- **Backend**: Payment methods are securely stored in PostgreSQL
- **Validation**: CVV is validated but not stored (as per PCI DSS)

---

## 🎯 Key Success Metrics to Highlight

- ✅ Seamless 3-click booking process
- ✅ Secure payment method storage
- ✅ Beautiful, modern UI
- ✅ Multi-card support
- ✅ Default payment selection
- ✅ Real-time booking confirmation

---

**Ready to demo!** 🎉

