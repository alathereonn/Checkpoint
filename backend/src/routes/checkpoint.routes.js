const r=require('express').Router(),c=require('../controllers/checkpoint.controller');r.get('/:id',c.get);r.put('/:id',c.update);r.delete('/:id',c.remove);module.exports=r;
