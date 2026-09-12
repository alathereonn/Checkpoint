const axios=require('axios');
async function request(path,params={}) { if(!process.env.RAWG_API_KEY){const e=new Error('RAWG API key is not configured');e.status=503;throw e;} const {data}=await axios.get(`https://api.rawg.io/api${path}`,{params:{...params,key:process.env.RAWG_API_KEY},timeout:10000}); return data; }
const map=g=>({external_game_id:String(g.id),title:g.name,cover_url:g.background_image,release_date:g.released,platforms:(g.platforms||[]).map(x=>x.platform.name)});
exports.search=async q=>(await request('/games',{search:q,page_size:20})).results.map(map);
exports.detail=async id=>map(await request(`/games/${encodeURIComponent(id)}`));
