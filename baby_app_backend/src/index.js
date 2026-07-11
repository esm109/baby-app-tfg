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

app.get('/baby-size-all', async (req, res) => {
  try {
    const result = await pool.query(
      `
      SELECT
        id,
        week_number,
        comparison_type,
        title,
        emoji,
        description,
        size_text,
        order_index
      FROM baby_size_comparisons
      ORDER BY week_number ASC, comparison_type ASC
      `
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error en /baby-size-all:', error);

    res.status(500).json({
      error: 'Error al obtener todas las comparaciones',
      details: error.message,
    });
  }
});

app.get('/baby-size-count', async (req, res) => {
  try {
    const result = await pool.query(
      `
      SELECT
        week_number,
        COUNT(*) AS total
      FROM baby_size_comparisons
      GROUP BY week_number
      ORDER BY week_number ASC
      `
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error en /baby-size-count:', error);

    res.status(500).json({
      error: 'Error al contar comparaciones',
      details: error.message,
    });
  }
});

app.get('/insert-missing-baby-sizes', async (req, res) => {
  try {
    const result = await pool.query(
      `
      WITH new_rows AS (
        SELECT *
        FROM (
          VALUES
            (10, 'fruit', 'Como una fresa pequeña', '🍓', 'Tu bebé empieza a tener una forma más definida y su tamaño recuerda al de una fresa pequeña.', 'Fresa pequeña', 1),
            (10, 'animal', 'Como un caracol pequeño', '🐌', 'Una comparación sencilla para imaginar su tamaño en esta etapa.', 'Caracol pequeño', 2),
            (10, 'object', 'Como una goma de borrar', '🧽', 'Su tamaño puede compararse con un objeto pequeño de uso cotidiano.', 'Goma de borrar', 3),

            (14, 'fruit', 'Como un limón', '🍋', 'Tu bebé sigue creciendo y ya puede compararse con el tamaño aproximado de un limón.', 'Limón', 1),
            (14, 'animal', 'Como un pollito pequeño', '🐥', 'Una referencia visual para imaginar su tamaño en esta semana.', 'Pollito pequeño', 2),
            (14, 'object', 'Como una pelota de tenis pequeña', '🎾', 'Su tamaño empieza a ser más fácil de imaginar con objetos cotidianos.', 'Pelota pequeña', 3),

            (16, 'fruit', 'Como un aguacate', '🥑', 'Tu bebé continúa creciendo y puede recordar al tamaño de un aguacate.', 'Aguacate', 1),
            (16, 'animal', 'Como un hámster pequeño', '🐹', 'Una comparación cercana para visualizar su tamaño aproximado.', 'Hámster pequeño', 2),
            (16, 'object', 'Como un teléfono pequeño', '📱', 'Su tamaño ya es más perceptible y fácil de comparar.', 'Teléfono pequeño', 3),

            (18, 'fruit', 'Como un pimiento', '🫑', 'Tu bebé alcanza un tamaño similar al de un pimiento.', 'Pimiento', 1),
            (18, 'animal', 'Como una ardilla pequeña', '🐿️', 'Una referencia aproximada para imaginar su crecimiento.', 'Ardilla pequeña', 2),
            (18, 'object', 'Como un mando pequeño', '🎮', 'Su tamaño puede compararse con un pequeño mando.', 'Mando pequeño', 3),

            (20, 'fruit', 'Como un plátano', '🍌', 'En esta etapa, tu bebé puede compararse con el tamaño aproximado de un plátano.', 'Plátano', 1),
            (20, 'animal', 'Como una cobaya pequeña', '🐹', 'Una comparación visual para representar su tamaño en la mitad del embarazo.', 'Cobaya pequeña', 2),
            (20, 'object', 'Como un mando de televisión', '📺', 'Su tamaño se parece al de un mando de televisión.', 'Mando de televisión', 3),

            (22, 'fruit', 'Como una papaya pequeña', '🧡', 'Tu bebé sigue ganando tamaño y puede compararse con una papaya pequeña.', 'Papaya pequeña', 1),
            (22, 'animal', 'Como un erizo pequeño', '🦔', 'Una referencia sencilla para visualizar su tamaño aproximado.', 'Erizo pequeño', 2),
            (22, 'object', 'Como una botella pequeña', '🍼', 'Su tamaño puede recordarte al de una botella pequeña.', 'Botella pequeña', 3),

            (24, 'fruit', 'Como una mazorca de maíz', '🌽', 'Tu bebé tiene un tamaño similar al de una mazorca de maíz.', 'Mazorca de maíz', 1),
            (24, 'animal', 'Como un conejito pequeño', '🐰', 'Una comparación amable para imaginar su tamaño.', 'Conejito pequeño', 2),
            (24, 'object', 'Como un estuche', '✏️', 'Su tamaño puede compararse con un estuche pequeño.', 'Estuche', 3),

            (26, 'fruit', 'Como una lechuga', '🥬', 'Tu bebé sigue creciendo y puede compararse con una lechuga.', 'Lechuga', 1),
            (26, 'animal', 'Como un gatito recién nacido', '🐱', 'Una referencia visual para esta etapa de desarrollo.', 'Gatito recién nacido', 2),
            (26, 'object', 'Como una botella de agua pequeña', '💧', 'Su tamaño puede recordar al de una botella pequeña.', 'Botella de agua pequeña', 3),

            (28, 'fruit', 'Como una berenjena', '🍆', 'Tu bebé alcanza un tamaño parecido al de una berenjena.', 'Berenjena', 1),
            (28, 'animal', 'Como un cachorro pequeño', '🐶', 'Una comparación sencilla para imaginar su tamaño.', 'Cachorro pequeño', 2),
            (28, 'object', 'Como una tablet pequeña', '📱', 'Su tamaño puede compararse con una tablet pequeña.', 'Tablet pequeña', 3),

            (30, 'fruit', 'Como un repollo', '🥬', 'Tu bebé continúa creciendo y puede compararse con un repollo.', 'Repollo', 1),
            (30, 'animal', 'Como un gato pequeño', '🐱', 'Una referencia aproximada para visualizar su tamaño.', 'Gato pequeño', 2),
            (30, 'object', 'Como una mochila pequeña', '🎒', 'Su tamaño empieza a recordar al de una mochila pequeña.', 'Mochila pequeña', 3),

            (32, 'fruit', 'Como una calabaza pequeña', '🎃', 'Tu bebé tiene ya un tamaño considerable, parecido al de una calabaza pequeña.', 'Calabaza pequeña', 1),
            (32, 'animal', 'Como un perrito pequeño', '🐶', 'Una comparación visual para imaginar su tamaño.', 'Perrito pequeño', 2),
            (32, 'object', 'Como un cojín pequeño', '🛏️', 'Su tamaño puede compararse con un cojín pequeño.', 'Cojín pequeño', 3),

            (34, 'fruit', 'Como un melón pequeño', '🍈', 'Tu bebé sigue ganando tamaño y puede compararse con un melón pequeño.', 'Melón pequeño', 1),
            (34, 'animal', 'Como un conejo grande', '🐇', 'Una referencia sencilla para imaginar su tamaño.', 'Conejo grande', 2),
            (34, 'object', 'Como una almohada pequeña', '🛏️', 'Su tamaño recuerda al de una almohada pequeña.', 'Almohada pequeña', 3),

            (36, 'fruit', 'Como una piña', '🍍', 'Tu bebé se acerca a su tamaño final y puede compararse con una piña.', 'Piña', 1),
            (36, 'animal', 'Como un gato mediano', '🐈', 'Una comparación visual para esta fase avanzada.', 'Gato mediano', 2),
            (36, 'object', 'Como una bolsa de deporte pequeña', '🎒', 'Su tamaño puede recordar al de una bolsa pequeña.', 'Bolsa de deporte pequeña', 3),

            (38, 'fruit', 'Como una sandía pequeña', '🍉', 'Tu bebé ya tiene un tamaño cercano al de un recién nacido.', 'Sandía pequeña', 1),
            (38, 'animal', 'Como un cachorro mediano', '🐕', 'Una referencia aproximada para visualizar su tamaño.', 'Cachorro mediano', 2),
            (38, 'object', 'Como una manta doblada', '🧺', 'Su tamaño puede compararse con una manta doblada.', 'Manta doblada', 3),

            (40, 'fruit', 'Como una sandía', '🍉', 'Tu bebé está preparado para nacer y su tamaño puede compararse con una sandía.', 'Sandía', 1),
            (40, 'animal', 'Como un bebé recién nacido', '👶', 'Una comparación directa con el tamaño esperado al final del embarazo.', 'Bebé recién nacido', 2),
            (40, 'object', 'Como una mochila llena', '🎒', 'Su tamaño puede recordar al de una mochila llena.', 'Mochila llena', 3)
        ) AS v(week_number, comparison_type, title, emoji, description, size_text, order_index)
      ),
      numbered_rows AS (
        SELECT
          (SELECT COALESCE(MAX(id), 0) FROM baby_size_comparisons)
          + ROW_NUMBER() OVER (ORDER BY week_number, order_index) AS id,
          week_number,
          comparison_type,
          title,
          emoji,
          description,
          size_text,
          order_index
        FROM new_rows
        WHERE NOT EXISTS (
          SELECT 1
          FROM baby_size_comparisons b
          WHERE b.week_number = new_rows.week_number
            AND b.comparison_type = new_rows.comparison_type
        )
      )
      INSERT INTO baby_size_comparisons
      (id, week_number, comparison_type, title, emoji, description, size_text, order_index)
      SELECT
        id,
        week_number,
        comparison_type,
        title,
        emoji,
        description,
        size_text,
        order_index
      FROM numbered_rows
      RETURNING week_number, comparison_type, title;
      `
    );

    res.json({
      inserted: result.rowCount,
      rows: result.rows,
    });
  } catch (error) {
    console.error('Error insertando tamaños:', error);
    res.status(500).json({
      error: 'Error insertando tamaños',
      details: error.message,
    });
  }
});

app.get('/baby-size/:week', async (req, res) => {
  const week = parseInt(req.params.week, 10);

  try {
    if (Number.isNaN(week) || week < 1 || week > 40) {
      return res.status(400).json({
        error: 'Semana no válida',
      });
    }

    const result = await pool.query(
      `
      SELECT
        id,
        week_number,
        comparison_type,
        title,
        emoji,
        description
      FROM baby_size_comparisons
      WHERE week_number = (
        SELECT MAX(week_number)
        FROM baby_size_comparisons
        WHERE week_number <= $1
      )
      ORDER BY comparison_type
      `,
      [week]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'No hay comparación disponible para esta semana',
      });
    }

    res.json(result.rows);
  } catch (error) {
    console.error('Error en /baby-size/:week:', error);
    res.status(500).json({
      error: 'Error al obtener comparación de tamaño',
      details: error.message,
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

  if (!message?.trim()) {
    return res.status(400).json({
      error: 'El mensaje no puede estar vacío',
    });
  }

  try {
    const historyText = Array.isArray(conversationHistory)
      ? conversationHistory
          .map(
            (m) =>
              `${m.isUser ? 'Usuario' : 'Asistente'}: ${m.text}`
          )
          .join('\n')
      : '';
    const prompt = `
      Eres un asistente virtual dentro de una app de embarazo.

      Contexto de la usuaria:
      - Semana de embarazo: ${selectedWeek ?? 'No disponible'}
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
      ${historyText || 'Sin historial previo'}

      Pregunta de la usuaria:
      ${message}
    `;
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
