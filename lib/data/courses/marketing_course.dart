import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../models/quiz.dart';

final Course marketingCourse = Course(
  id: 'bus_marketing_101',
  title: 'Digital Marketing Essentials',
  description: 'Learn SEO, Social Media Marketing, and Email strategies to grow your brand online.',
  category: 'Business',
  icon: Icons.campaign_rounded,
  color: const Color(0xFF4CAF50), // Green
  gradientEnd: const Color(0xFF388E3C),
  lessons: const [
    Lesson(
      id: 'm_l1',
      courseId: 'bus_marketing_101',
      title: 'Introduction to Digital Marketing',
      durationMinutes: 20,
      orderIndex: 0,
      content: 'Digital marketing encompasses all marketing efforts that use an electronic device or the internet.\n\nKey channels:\n• SEO (Search Engine Optimization)\n• Content Marketing\n• Social Media Marketing\n• PPC (Pay-Per-Click)\n• Email Marketing',
      quizzes: [
        Quiz(id: 'm_l1_q1', courseId: 'bus_marketing_101', question: 'What is digital marketing?', options: ['Marketing on TV', 'Marketing using electronic devices and the internet', 'Printing flyers', 'Word of mouth'], correctIndex: 1),
        Quiz(id: 'm_l1_q2', courseId: 'bus_marketing_101', question: 'What does SEO stand for?', options: ['Search Engine Optimization', 'Social Engagement Online', 'Sales Executive Officer', 'Standard Evaluation Operation'], correctIndex: 0),
        Quiz(id: 'm_l1_q3', courseId: 'bus_marketing_101', question: 'Which is NOT a digital marketing channel?', options: ['Email Marketing', 'PPC', 'Billboard Advertising', 'Social Media'], correctIndex: 2),
        Quiz(id: 'm_l1_q4', courseId: 'bus_marketing_101', question: 'What does PPC stand for?', options: ['Paper Per Click', 'Pay Per Click', 'Post Per Campaign', 'Provide Public Content'], correctIndex: 1),
        Quiz(id: 'm_l1_q5', courseId: 'bus_marketing_101', question: 'Why is digital marketing important?', options: ['It is expensive', 'It allows you to reach a global audience and measure results', 'It is a fad', 'Only large companies can use it'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'm_l2',
      courseId: 'bus_marketing_101',
      title: 'SEO Basics',
      durationMinutes: 30,
      orderIndex: 1,
      content: 'Search Engine Optimization (SEO) is the process of optimizing your website to rank higher in search engine results pages (SERPs).\n\n• On-Page SEO: Optimizing individual web pages (keywords, meta descriptions, content quality).\n• Off-Page SEO: Actions taken outside your website to impact rankings (backlinks from other sites).\n• Technical SEO: Improving the backend of your site (site speed, mobile-friendliness).',
      quizzes: [
        Quiz(id: 'm_l2_q1', courseId: 'bus_marketing_101', question: 'What is the goal of SEO?', options: ['To make the website look good', 'To rank higher in search engine results', 'To send emails', 'To print flyers'], correctIndex: 1),
        Quiz(id: 'm_l2_q2', courseId: 'bus_marketing_101', question: 'What does SERP stand for?', options: ['Search Engine Results Page', 'Social Engagement Ranking Platform', 'Sales Evaluation Report Page', 'System Error Repair Protocol'], correctIndex: 0),
        Quiz(id: 'm_l2_q3', courseId: 'bus_marketing_101', question: 'Using relevant keywords in your blog post is an example of...', options: ['Off-Page SEO', 'Technical SEO', 'On-Page SEO', 'PPC'], correctIndex: 2),
        Quiz(id: 'm_l2_q4', courseId: 'bus_marketing_101', question: 'Getting another reputable website to link to your website is called...', options: ['A backlink', 'A meta tag', 'A keyword', 'A plugin'], correctIndex: 0),
        Quiz(id: 'm_l2_q5', courseId: 'bus_marketing_101', question: 'Improving your website\'s loading speed is part of...', options: ['On-Page SEO', 'Off-Page SEO', 'Technical SEO', 'Content Marketing'], correctIndex: 2),
      ],
    ),
    Lesson(
      id: 'm_l3',
      courseId: 'bus_marketing_101',
      title: 'Social Media Marketing',
      durationMinutes: 25,
      orderIndex: 2,
      content: 'Social media marketing uses social networks to achieve your marketing goals.\n\n• Organic: Free content shared with your audience.\n• Paid: Sponsored posts or ads that you pay to show to a specific target audience.\n\nDifferent platforms serve different purposes. LinkedIn is for B2B (Business to Business), while Instagram is highly visual and great for B2C (Business to Consumer).',
      quizzes: [
        Quiz(id: 'm_l3_q1', courseId: 'bus_marketing_101', question: 'What is the difference between organic and paid social media?', options: ['Organic is healthy, paid is not', 'Organic is free, paid costs money', 'Organic is on Facebook, paid is on Twitter', 'There is no difference'], correctIndex: 1),
        Quiz(id: 'm_l3_q2', courseId: 'bus_marketing_101', question: 'Which platform is best known for B2B (Business to Business) networking?', options: ['TikTok', 'Instagram', 'LinkedIn', 'Snapchat'], correctIndex: 2),
        Quiz(id: 'm_l3_q3', courseId: 'bus_marketing_101', question: 'What does B2C stand for?', options: ['Business to Corporation', 'Business to Consumer', 'Brand to Company', 'Buyer to Creator'], correctIndex: 1),
        Quiz(id: 'm_l3_q4', courseId: 'bus_marketing_101', question: 'Why use paid social media ads?', options: ['Because organic reach is always enough', 'To target a very specific demographic quickly', 'To hide your content', 'Because the platforms force you to'], correctIndex: 1),
        Quiz(id: 'm_l3_q5', courseId: 'bus_marketing_101', question: 'True or False: The same content strategy works perfectly on every social media platform.', options: ['True', 'False, each platform has a different audience and format', 'Only for large companies', 'Only for videos'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'm_l4',
      courseId: 'bus_marketing_101',
      title: 'Email Marketing',
      durationMinutes: 20,
      orderIndex: 3,
      content: 'Email marketing is highly effective because you own your list of subscribers.\n\n• Lead Magnet: A free item (like an ebook) given away in exchange for an email address.\n• Open Rate: The percentage of people who open your email.\n• CTR (Click-Through Rate): The percentage of people who click a link inside your email.\n\nAlways provide value; don\'t just sell.',
      quizzes: [
        Quiz(id: 'm_l4_q1', courseId: 'bus_marketing_101', question: 'Why is email marketing considered powerful?', options: ['Because nobody uses email', 'Because you own your subscriber list', 'Because it is always ignored', 'Because it costs thousands of dollars'], correctIndex: 1),
        Quiz(id: 'm_l4_q2', courseId: 'bus_marketing_101', question: 'What is a Lead Magnet?', options: ['A literal magnet', 'A free item given in exchange for an email address', 'An expensive product', 'A type of virus'], correctIndex: 1),
        Quiz(id: 'm_l4_q3', courseId: 'bus_marketing_101', question: 'What metric measures the percentage of people who opened your email?', options: ['Bounce Rate', 'Click-Through Rate (CTR)', 'Open Rate', 'Conversion Rate'], correctIndex: 2),
        Quiz(id: 'm_l4_q4', courseId: 'bus_marketing_101', question: 'What does CTR stand for?', options: ['Click-Through Rate', 'Count Total Reach', 'Customer Tracking Ratio', 'Call To Review'], correctIndex: 0),
        Quiz(id: 'm_l4_q5', courseId: 'bus_marketing_101', question: 'What is a good rule of thumb for email marketing?', options: ['Sell in every email', 'Provide value, don\'t just sell', 'Send 5 emails a day', 'Never use a subject line'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'm_l5',
      courseId: 'bus_marketing_101',
      title: 'Analytics & KPIs',
      durationMinutes: 25,
      orderIndex: 4,
      content: 'You can\'t improve what you don\'t measure. Google Analytics is a standard tool for website measurement.\n\n• KPI (Key Performance Indicator): A measurable value that demonstrates how effectively a company is achieving objectives.\n• Bounce Rate: The percentage of visitors who navigate away from the site after viewing only one page.\n• Conversion Rate: The percentage of visitors who take a desired action (like buying a product).',
      quizzes: [
        Quiz(id: 'm_l5_q1', courseId: 'bus_marketing_101', question: 'What does KPI stand for?', options: ['Key Performance Indicator', 'Known Public Interest', 'Key Product Information', 'Knowledge Processing Index'], correctIndex: 0),
        Quiz(id: 'm_l5_q2', courseId: 'bus_marketing_101', question: 'What does a high Bounce Rate indicate?', options: ['People love your site', 'People are leaving your site after viewing only one page', 'People are buying a lot of products', 'Your site is very fast'], correctIndex: 1),
        Quiz(id: 'm_l5_q3', courseId: 'bus_marketing_101', question: 'If 100 people visit your site and 5 people buy something, what is your Conversion Rate?', options: ['100%', '50%', '5%', '0.5%'], correctIndex: 2),
        Quiz(id: 'm_l5_q4', courseId: 'bus_marketing_101', question: 'Which tool is industry-standard for measuring website traffic?', options: ['Microsoft Word', 'Google Analytics', 'Adobe Photoshop', 'Zoom'], correctIndex: 1),
        Quiz(id: 'm_l5_q5', courseId: 'bus_marketing_101', question: 'Why is analytics important in digital marketing?', options: ['It allows you to measure results and improve campaigns', 'It makes the website look pretty', 'It forces people to buy', 'It is not important'], correctIndex: 0),
      ],
    ),
  ],
  quizzes: const [
    Quiz(id: 'm_final_q1', courseId: 'bus_marketing_101', question: 'What does SEO stand for?', options: ['Search Engine Optimization', 'Social Engagement Online', 'Sales Executive Officer', 'Standard Evaluation Operation'], correctIndex: 0),
    Quiz(id: 'm_final_q2', courseId: 'bus_marketing_101', question: 'Which SEO type involves getting backlinks?', options: ['On-Page SEO', 'Technical SEO', 'Off-Page SEO', 'Local SEO'], correctIndex: 2),
    Quiz(id: 'm_final_q3', courseId: 'bus_marketing_101', question: 'Which platform is best for B2B marketing?', options: ['Instagram', 'LinkedIn', 'TikTok', 'Snapchat'], correctIndex: 1),
    Quiz(id: 'm_final_q4', courseId: 'bus_marketing_101', question: 'What is a Lead Magnet?', options: ['A free item in exchange for an email', 'A physical magnet', 'A sales pitch', 'A spam email'], correctIndex: 0),
    Quiz(id: 'm_final_q5', courseId: 'bus_marketing_101', question: 'What does Bounce Rate measure?', options: ['How many people bought a product', 'How many people opened an email', 'The percentage of visitors who leave after viewing one page', 'How fast the site loads'], correctIndex: 2),
  ],
);
