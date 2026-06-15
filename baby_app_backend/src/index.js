const express = require('express');
const cors = require('cors');
const pool = require('./db');
require('dotenv').config();
const { GoogleGenAI } = require('@google/genai');

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

const app = express();

app.use(cors());
app.use(express.json());

app.get('/message', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, content FROM messages ORDER BY id ASC LIMIT 1'
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'No message found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error en /message:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/categories', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name FROM categories ORDER BY id ASC'
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error en /categories:', error);
    res.status(500).json({ error: 'Error al obtener categorías' });
  }
});

app.get('/stages', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, name, start_week, end_week, short_description, key_points, media_type, media_url, order_index
      FROM stages
      ORDER BY order_index ASC
    `);

    res.json(result.rows);
  } catch (error) {
    console.error('Error en /stages:', error);
    res.status(500).json({ error: 'Error al obtener etapas' });
  }
});

app.get('/tips', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, title, content, category_id, stage_id FROM tips ORDER BY id ASC'
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error en /tips:', error);
    res.status(500).json({ error: 'Error al obtener tips' });
  }
});

app.get('/tips/category/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'SELECT id, title, content, category_id, stage_id FROM tips WHERE category_id = $1 ORDER BY id ASC',
      [id]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error en /tips/category/:id:', error);
    res.status(500).json({ error: 'Error al obtener tips por categoría' });
  }
});

app.get('/stages', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM stages ORDER BY order_index ASC'
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener stages:', error);
    res.status(500).json({ error: 'Error al obtener las etapas' });
  }
});

app.get('/stages/:id/baby-development', async (req, res) => {
  const stageId = req.params.id;

  try {
    const result = await pool.query(
      `SELECT * 
       FROM stage_baby_development 
       WHERE stage_id = $1 
       ORDER BY order_index ASC`,
      [stageId]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener baby development:', error);
    res.status(500).json({ error: 'Error al obtener el desarrollo del bebé' });
  }
});

app.get('/stages/:id/mother-changes', async (req, res) => {
  const stageId = req.params.id;

  try {
    const result = await pool.query(
      `SELECT * 
       FROM stage_mother_changes 
       WHERE stage_id = $1 
       ORDER BY order_index ASC`,
      [stageId]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener mother changes:', error);
    res.status(500).json({ error: 'Error al obtener los cambios de la madre' });
  }
});

app.get('/stages/:id/recommendations', async (req, res) => {
  const stageId = req.params.id;

  try {
    const result = await pool.query(
      `SELECT * 
       FROM stage_recommendations 
       WHERE stage_id = $1 
       ORDER BY order_index ASC`,
      [stageId]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener recommendations:', error);
    res.status(500).json({ error: 'Error al obtener las recomendaciones' });
  }
});

app.get('/stages/:id/details', async (req, res) => {
  const stageId = req.params.id;

  try {
    const stage = await pool.query(
      'SELECT * FROM stages WHERE id = $1',
      [stageId]
    );

    const babyDevelopment = await pool.query(
      'SELECT * FROM stage_baby_development WHERE stage_id = $1 ORDER BY order_index ASC',
      [stageId]
    );

    const motherChanges = await pool.query(
      'SELECT * FROM stage_mother_changes WHERE stage_id = $1 ORDER BY order_index ASC',
      [stageId]
    );

    const recommendations = await pool.query(
      'SELECT * FROM stage_recommendations WHERE stage_id = $1 ORDER BY order_index ASC',
      [stageId]
    );

    res.json({
      stage: stage.rows[0],
      baby_development: babyDevelopment.rows,
      mother_changes: motherChanges.rows,
      recommendations: recommendations.rows
    });
  } catch (error) {
    console.error('Error al obtener detalles de la etapa:', error);
    res.status(500).json({ error: 'Error al obtener los detalles de la etapa' });
  }
});

app.get('/stages/:id/details', async (req, res) => {
  const stageId = req.params.id;

  try {
    const stage = await pool.query(`
      SELECT id, name, start_week, end_week, short_description, key_points, media_type, media_url, order_index
      FROM stages
      WHERE id = $1`,
      [stageId]
    );

    const babyDevelopment = await pool.query(
      `SELECT id, stage_id, title, description, week_reference, order_index
       FROM stage_baby_development
       WHERE stage_id = $1
       ORDER BY order_index ASC`,
      [stageId]
    );

    const motherChanges = await pool.query(
      `SELECT id, stage_id, symptom, description, type, order_index
       FROM stage_mother_changes
       WHERE stage_id = $1
       ORDER BY order_index ASC`,
      [stageId]
    );

    const recommendations = await pool.query(
      `SELECT id, stage_id, recommendation, category, priority, order_index
       FROM stage_recommendations
       WHERE stage_id = $1
       ORDER BY order_index ASC`,
      [stageId]
    );

    res.json({
      stage: stage.rows[0],
      babyDevelopment: babyDevelopment.rows,
      motherChanges: motherChanges.rows,
      recommendations: recommendations.rows
    });
  } catch (error) {
    console.error('Error en /stages/:id/details:', error);
    res.status(500).json({ error: 'Error al obtener detalles de la etapa' });
  }
});

app.get('/baby-size/:week', async (req, res) => {
  const week = req.params.week;

  try {
    const selectedWeek = await pool.query(
      `SELECT week_number
       FROM baby_size_comparisons
       WHERE week_number <= $1
       ORDER BY week_number DESC
       LIMIT 1`,
      [week]
    );

    if (selectedWeek.rows.length === 0) {
      return res.status(404).json({
        error: 'No hay comparación disponible para esta semana'
      });
    }

    const weekNumber = selectedWeek.rows[0].week_number;

    const result = await pool.query(
      `SELECT id, week_number, comparison_type, title, emoji, description, size_text, order_index
       FROM baby_size_comparisons
       WHERE week_number = $1
       ORDER BY order_index ASC
       LIMIT 4`,
      [weekNumber]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error en /baby-size/:week:', error);
    res.status(500).json({
      error: 'Error al obtener comparación de tamaño',
      details: error.message
    });
  }
});

app.get('/weekly-tip/:week', async (req, res) => {
  const week = req.params.week;

  try {
    const result = await pool.query(
      `SELECT id, week_number, title, description, category, priority, order_index
       FROM weekly_tips
       WHERE week_number <= $1
       ORDER BY week_number DESC
       LIMIT 1`,
      [week]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'No hay consejo disponible para esta semana'
      });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error en /weekly-tip/:week:', error);
    res.status(500).json({
      error: 'Error al obtener consejo semanal',
      details: error.message
    });
  }
});

app.get('/checklist/:week', async (req, res) => {
  const week = req.params.week;

  try {
    const selectedWeek = await pool.query(
      `SELECT week_number
       FROM weekly_checklists
       WHERE week_number <= $1
       ORDER BY week_number DESC
       LIMIT 1`,
      [week]
    );

    if (selectedWeek.rows.length === 0) {
      return res.json([]);
    }

    const weekNumber = selectedWeek.rows[0].week_number;

    const result = await pool.query(
      `SELECT id, week_number, task, category, order_index
       FROM weekly_checklists
       WHERE week_number = $1
       ORDER BY order_index ASC`,
      [weekNumber]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error en /checklist/:week:', error);
    res.status(500).json({
      error: 'Error al obtener checklist semanal',
      details: error.message
    });
  }
});

app.get('/appointments/:week', async (req, res) => {
  const week = req.params.week;

  try {
    const result = await pool.query(
      `SELECT id, week_number, title, description, appointment_type, order_index
       FROM pregnancy_appointments
       WHERE week_number >= $1
       ORDER BY week_number ASC
       LIMIT 3`,
      [week]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error en /appointments/:week:', error);
    res.status(500).json({
      error: 'Error al obtener próximas citas',
      details: error.message
    });
  }
});

app.get('/hospital-bag', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM hospital_bag_items
       ORDER BY order_index ASC`
    );

    res.json(result.rows);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: 'Error al obtener bolsa hospital',
    });
  }
});

app.get('/', (req, res) => {
  res.send('API Baby App funcionando');
});

const PORT = process.env.PORT || 3000;

app.post('/chat', async (req, res) => {
  const {
    message,
    selectedWeek,
    mood,
    lastDiaryEntry,
    hospitalBagProgress,
    conversationHistory
  } = req.body;

  try {
    const prompt = `
Eres un asistente virtual dentro de una app de embarazo.

Contexto de la usuaria:
- Semana de embarazo: ${selectedWeek}
- Estado de ánimo registrado: ${mood || 'No disponible'}
- Última entrada del diario: ${lastDiaryEntry || 'No disponible'}
- Progreso de bolsa hospitalaria: ${hospitalBagProgress || 'No disponible'}

Instrucciones:
- Responde siempre en español.
- Usa un tono cercano, claro, tranquilizador y breve.
- Personaliza la respuesta según la semana de embarazo y el contexto disponible.
- No des diagnósticos médicos.
- Si la usuaria menciona sangrado, dolor intenso, fiebre, pérdida de líquido, mareos fuertes, contracciones regulares o preocupación importante, recomienda consultar con un profesional sanitario.

Historial reciente:
${historyText}

Pregunta de la usuaria:
${message}
`;

    const historyText =
      conversationHistory
        ?.map(m =>
          `${m.isUser ? 'Usuario' : 'Asistente'}: ${m.text}`
        )
        .join('\n') || '';

    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: prompt,
    });

    res.json({
      reply: response.text,
    });
  } catch (error) {
    console.error('Error en /chat:', error);
    res.status(500).json({
      error: 'Error al generar respuesta del asistente',
      details: error.message,
    });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});


