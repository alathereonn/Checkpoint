const r=require('express').Router(),c=require('../controllers/game.controller');r.get('/search',c.search);r.get('/external/:externalId',c.detail);module.exports=r;
