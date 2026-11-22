import '../models/protocol.dart';

const maternalProtocol = Protocol(
  id: 'maternal-danger-signs',
  title: 'Maternal danger signs',
  version: '1.0.0',
  source: 'WHO/IMNCI-aligned danger signs (illustrative excerpt)',
  questions: [
    Question(
      id: 'danger_bleeding',
      hi: 'क्या महिला को भारी रक्तस्राव हो रहा है?',
      en: 'Is the woman bleeding heavily?',
      label: 'heavy bleeding',
      isRed: true,
    ),
    Question(
      id: 'convulsions',
      hi: 'क्या महिला को दौरे पड़ रहे हैं या वह बेहोश है?',
      en: 'Is she having convulsions or unconscious?',
      label: 'convulsions or unconsciousness',
      isRed: true,
    ),
    Question(
      id: 'severe_headache',
      hi: 'क्या उसे तेज़ सिरदर्द या धुंधला दिखाई दे रहा है?',
      en: 'Does she have a severe headache or blurred vision?',
      label: 'severe headache or blurred vision',
      isRed: false,
    ),
    Question(
      id: 'reduced_fetal_movement',
      hi: 'क्या बच्चे की हरकत कम हो गई है?',
      en: "Has the baby's movement reduced?",
      label: 'reduced fetal movement',
      isRed: false,
    ),
  ],
  terminals: {
    Risk.red: Terminal(
      id: 'emergency_referral',
      risk: Risk.red,
      badge: 'RED',
      title: 'Refer immediately',
      action:
          'Do not wait for the next routine visit. Arrange transport to the nearest PHC or FRU now.',
      steps: [
        'Arrange transport to the nearest PHC or FRU now.',
        'Do not wait for the next routine visit.',
        'Generate the referral slip before leaving.',
      ],
    ),
    Risk.amber: Terminal(
      id: 'same_day_referral',
      risk: Risk.amber,
      badge: 'AMBER',
      title: 'Refer today',
      action:
          'Arrange a same-day review at the PHC or FRU. Do not wait for the next routine visit.',
      steps: [
        'Arrange a same-day visit to the PHC or FRU.',
        'Do not wait for the next routine visit.',
        'Generate the referral slip and hand it to the family.',
      ],
    ),
    Risk.green: Terminal(
      id: 'routine_care',
      risk: Risk.green,
      badge: 'GREEN',
      title: 'Continue routine care',
      action:
          'No danger signs recorded. Continue routine antenatal care and counsel the family on when to return.',
      steps: [
        'Continue routine antenatal check-ups.',
        'Counsel the family on danger signs.',
        'Screen again if any danger sign appears.',
      ],
    ),
  },
);
