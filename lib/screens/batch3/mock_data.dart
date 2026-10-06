/// Mock data copied from the web pages (FindDoctor.jsx, DoctorPatients.jsx).
class Doctor {
  const Doctor(this.name, this.specialty, this.experience, this.rating, this.available);
  final String name, specialty, experience, rating, available;
}

const doctors = [
  Doctor('Dr. Ananya Rao', 'General Physician', '12 years', '4.9', 'Today'),
  Doctor('Dr. Rahul Sharma', 'Hematologist', '15 years', '4.8', 'Tomorrow'),
  Doctor('Dr. Priya Menon', 'Internal Medicine', '10 years', '4.7', 'Today'),
];

const doctorPatients = ['Ananya Sharma', 'Meera Patel', 'Kavya Nair'];
