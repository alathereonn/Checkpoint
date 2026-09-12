const rawg=require('../services/rawg.service');
exports.search=async(req,res)=>{if(!req.query.q?.trim())return res.status(422).json({success:false,message:'Search query is required',errors:[]});res.json({success:true,data:await rawg.search(req.query.q.trim())});};
exports.detail=async(req,res)=>res.json({success:true,data:await rawg.detail(req.params.externalId)});
