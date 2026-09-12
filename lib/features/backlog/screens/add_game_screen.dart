import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/game.dart';

class AddGameScreen extends StatelessWidget {
  const AddGameScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Add Game')), body: ListView(padding: const EdgeInsets.all(20), children: [
    ListTile(leading: const Icon(Icons.travel_explore), title: const Text('Search Game'), subtitle: const Text('Search covers and metadata through RAWG'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchGameScreen()))),
    const SizedBox(height: 12),
    ListTile(leading: const Icon(Icons.edit), title: const Text('Add Manually'), subtitle: const Text('Upload your own game and cover'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualGameScreen()))),
  ]);
}

class SearchGameScreen extends ConsumerStatefulWidget { const SearchGameScreen({super.key}); @override ConsumerState<SearchGameScreen> createState() => _SearchState(); }
class _SearchState extends ConsumerState<SearchGameScreen> {
  final query = TextEditingController(); List<ExternalGame> games=[]; bool loading=false; String? error;
  Future<void> search() async { setState(() { loading=true; error=null; }); try { final data=await ref.read(apiProvider).get('/api/games/search',query:{'q':query.text}); games=(data as List).map((e)=>ExternalGame.fromJson(Map<String,dynamic>.from(e))).toList(); } catch(e) { error='Unable to search online games. You can still add the game manually.\n$e'; } finally { if(mounted)setState(()=>loading=false); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Search RAWG')), body: Column(children: [
    Padding(padding: const EdgeInsets.all(16), child: TextField(controller: query, onSubmitted: (_)=>search(), decoration: InputDecoration(hintText:'Elden Ring', prefixIcon:const Icon(Icons.search), suffixIcon:IconButton(onPressed:search,icon:const Icon(Icons.arrow_forward))))),
    if(loading) const LinearProgressIndicator(), if(error!=null) Padding(padding:const EdgeInsets.all(16),child:Text(error!,textAlign:TextAlign.center)),
    Expanded(child: ListView.builder(itemCount:games.length,itemBuilder:(_,i){final g=games[i];return ListTile(leading:g.coverUrl==null?const Icon(Icons.sports_esports):Image.network(g.coverUrl!,width:54,height:72,fit:BoxFit.cover),title:Text(g.title),subtitle:Text(g.platforms.join(', ')),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ConfigureGameScreen(game:g))));})),
  ]));
}

class ConfigureGameScreen extends ConsumerStatefulWidget { const ConfigureGameScreen({super.key,required this.game}); final ExternalGame game; @override ConsumerState<ConfigureGameScreen> createState()=>_ConfigureState(); }
class _ConfigureState extends ConsumerState<ConfigureGameScreen> {
  String? platform; String status='plan_to_play'; bool saving=false;
  Future<void> save() async { setState(()=>saving=true); try { await ref.read(apiProvider).post('/api/backlog',data:{'external_game_id':widget.game.externalId,'source':'rawg','title':widget.game.title,'cover_url':widget.game.coverUrl,'release_date':widget.game.releaseDate,'platform':platform,'status':status}); if(mounted)Navigator.popUntil(context,(r)=>r.isFirst); } catch(e) { if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e'))); } finally { if(mounted)setState(()=>saving=false); } }
  @override Widget build(BuildContext context) { platform??=widget.game.platforms.firstOrNull??'PC'; return Scaffold(appBar:AppBar(title:Text(widget.game.title)),body:ListView(padding:const EdgeInsets.all(20),children:[if(widget.game.coverUrl!=null)Image.network(widget.game.coverUrl!,height:260,fit:BoxFit.cover),const SizedBox(height:16),DropdownButtonFormField<String>(initialValue:platform,decoration:const InputDecoration(labelText:'Platform'),items:{...widget.game.platforms,platform!}.map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>platform=v),const SizedBox(height:12),StatusField(value:status,onChanged:(v)=>status=v!),const SizedBox(height:20),FilledButton(onPressed:saving?null:save,child:Text(saving?'Adding…':'Add to Backlog'))])); }
}

class ManualGameScreen extends ConsumerStatefulWidget { const ManualGameScreen({super.key}); @override ConsumerState<ManualGameScreen> createState()=>_ManualState(); }
class _ManualState extends ConsumerState<ManualGameScreen> {
  final title=TextEditingController(),platform=TextEditingController(text:'PC'); String status='plan_to_play'; XFile? cover; bool saving=false;
  Future<void> save() async { if(title.text.trim().isEmpty||platform.text.trim().isEmpty)return; setState(()=>saving=true); try { String? url; if(cover!=null){final form=FormData.fromMap({'cover':await MultipartFile.fromFile(cover!.path,filename:cover!.name)});final data=await ref.read(apiProvider).post('/api/uploads/game-cover',data:form);url=data['cover_url'];}await ref.read(apiProvider).post('/api/backlog',data:{'source':'manual','title':title.text.trim(),'cover_url':url,'platform':platform.text.trim(),'status':status});if(mounted)Navigator.popUntil(context,(r)=>r.isFirst);}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}finally{if(mounted)setState(()=>saving=false);} }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Add Manually')),body:ListView(padding:const EdgeInsets.all(20),children:[TextField(controller:title,decoration:const InputDecoration(labelText:'Game name')),const SizedBox(height:12),TextField(controller:platform,decoration:const InputDecoration(labelText:'Platform')),const SizedBox(height:12),StatusField(value:status,onChanged:(v)=>status=v!),const SizedBox(height:12),OutlinedButton.icon(onPressed:()async{final x=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:85);if(x!=null)setState(()=>cover=x);},icon:const Icon(Icons.image),label:Text(cover?.name??'Choose cover')),const SizedBox(height:20),FilledButton(onPressed:saving?null:save,child:Text(saving?'Saving…':'Add to Backlog'))]);
}
class StatusField extends StatelessWidget { const StatusField({super.key,required this.value,required this.onChanged}); final String value; final ValueChanged<String?> onChanged; @override Widget build(BuildContext context)=>DropdownButtonFormField<String>(initialValue:value,decoration:const InputDecoration(labelText:'Status'),items:const [DropdownMenuItem(value:'plan_to_play',child:Text('Plan to Play')),DropdownMenuItem(value:'playing',child:Text('Playing')),DropdownMenuItem(value:'completed',child:Text('Completed'))],onChanged:onChanged); }
