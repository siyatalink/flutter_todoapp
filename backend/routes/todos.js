const express = require('express');
const Todo = require('../models/Todo');
const verifyToken = require('../middleware/auth'); // Import the middleware
const router = express.Router();

// Get all todos for a user
router.get('/', verifyToken, async (req, res) => {
  const todos = await Todo.find({ userId: req.userId });
  res.json(todos);
});

// Add a new todo
router.post('/', verifyToken, async (req, res) => {
  const newTodo = new Todo({
    userId: req.userId,
    task: req.body.task,
  });
  await newTodo.save();
  res.status(201).json(newTodo);
});

// Delete a todo
router.delete('/:id', verifyToken, async (req, res) => {
  await Todo.findByIdAndDelete(req.params.id);
  res.sendStatus(204);
});

module.exports = router;
