<!DOCTYPE html>
<html lang="pt-br" class="notranslate" translate="no">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <meta name="google" content="notranslate">
    <title>PIXXX - Oficial</title>
    
    <!-- Bibliotecas Necessárias -->
    <script src="https://download.agora.io/sdk/release/AgoraRTC_N-4.11.0.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script src="https://cdn.tailwindcss.com"></script>

    <style>
        body { background: #050505; color: white; font-family: sans-serif; margin: 0; padding: 0; overflow-x: hidden; }
        header { padding: 15px; border-bottom: 1px solid #222; background: #000; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 100; }
        .neon-purple { color: #bc13fe; text-shadow: 0 0 10px #bc13fe; font-weight: 900; }
        .aba-conteudo { display: none; padding: 15px; text-align: center; padding-bottom: 150px; }
        .aba-ativa { display: block !important; }
        footer { position: fixed; bottom: 0; width: 100%; max-width: 448px; background: #000; border-top: 1px solid #222; display: flex; justify-content: space-around; z-index: 1000; padding: 10px 0; }
        .nav-tab { color: #444; font-size: 10px; font-weight: bold; text-align: center; flex: 1; cursor: pointer; }
        .nav-active { color: #bc13fe !important; border-top: 2px solid #bc13fe; }
        .glass { background: rgba(255, 255, 255, 0.03); border: 1px solid #333; border-radius: 25px; padding: 15px; margin-bottom: 15px; }
        .bg-purple { background: linear-gradient(90deg, #bc13fe, #8a2be2); color: white; border-radius: 15px; padding: 15px; font-weight: bold; width: 100%; cursor: pointer; }
        input { background: #111; border: 1px solid #333; color: white; width: 100%; padding: 12px; border-radius: 10px; margin-bottom: 10px; outline: none; }
        #video-player { width: 100%; height: 350px; background: #000; border-radius: 35px; border: 1px solid #bc13fe; overflow: hidden; position: relative; }
    </style>

    <script>
        // NAVEGAÇÃO INFALÍVEL
        function mudarAba(id) {
            const abas = ['home', 'roulette', 'live', 'gems', 'gestao'];
            abas.forEach(a => {
                document.getElementById('tela-' + a).style.display = 'none';
                document.getElementById('btn-' + a).classList.remove('nav-active');
            });
            document.getElementById('tela-' + id).style.display = 'block';
            document.getElementById('btn-' + id).classList.add('nav-active');
            window.scrollTo(0,0);
        }
    </script>
</head>
<body class="max-w-md mx-auto">

    <header>
        <h1 class="text-2xl font-black italic neon-purple tracking-tighter">PIXXX</h1>
        <div style="color: #ffcc00; font-weight: bold; font-size: 11px;" id="topo-saldo">0 Gems</div>
    </header>

    <!-- TELA 1: FEED -->
    <div id="tela-home" class="aba-conteudo aba-ativa">
        <h2 class="text-[9px] font-black uppercase text-gray-600 mb-4 tracking-widest italic">Feed Privado</h2>
        <div class="glass" onclick="mudarAba('live')">
            <p style="text-align:left; font-size:12px; font-weight:bold; margin-bottom:10px;">Leticia_Hot 🔞</p>
            <img src="https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=400" style="width:100%; border-radius:15px; filter: blur(15px); opacity:0.5;">
            <button class="bg-purple" style="margin-top:10px; font-size:10px;">🔓 VER FOTO (10 GEMS)</button>
        </div>
    </div>

    <!-- TELA 2: ROLETA -->
    <div id="tela-roulette" class="aba-conteudo">
        <h2 class="neon-purple text-xl">ROLETA DA SORTE</h2>
        <div id="wheel" style="width:180px; height:180px; border-radius:50%; border:4px solid #bc13fe; margin:20px auto; display:flex; align-items:center; justify-content:center; opacity:0.3; font-size:8px;">SORTE | 5 | 30 | 250</div>
        <button onclick="girar()" class="bg-purple">GIRAR (15 GEMS)</button>
    </div>

    <!-- TELA 3: LIVE (CÂMERA E JOGOS) -->
    <div id="tela-live" class="aba-conteudo">
        <div id="video-player">
             <div id="bunny-ears" style="display:none; position: absolute; inset: 0; align-items: center; justify-content: center; font-size: 60px; pointer-events: none; margin-top: -160px;">🐰</div>
        </div>
        <div class="flex gap-2 my-4">
            <button onclick="document.getElementById('video-player').style.filter='saturate(1.8)'" class="glass text-[8px] flex-1">✨ DIVA</button>
            <button onclick="document.getElementById('bunny-ears').style.display='flex'" class="glass text-[8px] flex-1">🐰 COELHO</button>
        </div>
        <input id="nick" type="text" placeholder="Seu apelido...">
        <div class="grid grid-cols-2 gap-2">
            <button onclick="start('camera')" class="bg-purple text-[9px]">🎥 CÂMERA</button>
            <button onclick="start('game')" class="bg-purple text-[9px]" style="background:#ff4500;">🎮 JOGOS</button>
        </div>
        <button onclick="assistir()" class="bg-gray-800 w-full py-4 rounded-xl mt-2 font-bold text-[10px] uppercase">Assistir Live</button>
    </div>

    <!-- TELA 4: GEMS -->
    <div id="tela-gems" class="aba-conteudo">
        <h2 class="neon-purple text-xl mb-6 uppercase italic">Recarregar Gems</h2>
        <div style="display: grid; grid-template-cols: 1fr 1fr; gap: 10px;" id="loja-grid"></div>
        <div id="pix-area" style="display:none;" class="glass border-green-600 animate-pulse mt-4">
            <p style="color: #00ff00; font-size:9px; font-weight:bold;">CHAVE PIX PRESIDENTE:</p>
            <p style="font-size:10px; font-weight:bold; color:white;">0f549cdb-6acb-4af9-bd96-890360d4cdf8</p>
            <button onclick="window.open('https://wa.me/5567981251773')" class="bg-purple" style="background:white; color:black; font-size:10px; margin-top:10px;">JÁ PAGUEI! LIBERAR</button>
        </div>
    </div>

    <!-- TELA 5: GESTÃO -->
    <div id="tela-gestao" class="aba-conteudo">
        <div id="log-box">
            <h3 style="color:#666; font-size:9px; margin-bottom:20px;">ACESSO GESTÃO</h3>
            <input id="e-adm" type="text" placeholder="E-mail Gestão">
            <input id="s-adm" type="password" placeholder="Senha">
            <button onclick="logar()" class="bg-purple">ENTRAR NO PAINEL</button>
        </div>
        <div id="painel" style="display:none;" class="text-left">
            <div class="glass" style="background:#bc13fe; padding:30px;">
                <p style="font-size:8px; font-weight:bold; opacity:0.7;">ESTOQUE INFINITO</p>
                <h2 id="estoque-label" style="font-size:20px; font-weight:900;">100.000.000 GEMS</h2>
            </div>
            <div class="glass mt-2">
                <input id="l-nick" type="text" placeholder="Apelido Cliente">
                <input id="l-qtd" type="number" placeholder="Quantidade">
                <button onclick="liberarGems()" class="bg-purple" style="background:#28a745;">LIBERAR MOEDAS</button>
            </div>
        </div>
    </div>

    <footer>
        <div id="btn-home" onclick="mudarAba('home')" class="nav-tab nav-active">🏠<br>Feed</div>
        <div id="btn-roulette" onclick="mudarAba('roulette')" class="nav-tab">🎡<br>Sorte</div>
        <div id="btn-live" onclick="mudarAba('live')" class="nav-tab">🎥<br>Live</div>
        <div id="btn-gems" onclick="mudarAba('gems')" class="nav-tab">💎<br>Gems</div>
        <div id="btn-gestao" onclick="mudarAba('gestao')" class="nav-tab">👤<br>Gestão</div>
    </footer>

    <script>
        const _URL = 'https://uwjbmxxehcxaow.supabase.co';
        const _KEY = 'sb_publishable_cvsGGsWffdopP6ooo3Vqjw_D71XLKft';
        const supabase = supabase.createClient(_URL, _KEY);
        const appId = "58b921e58ceb4536b3bca7dd6a12bdba";
        const client = AgoraRTC.createClient({ mode: "live", codec: "vp8" });
        let tracks = { v: null, a: null };

        const grid = document.getElementById('loja-grid');
        [5, 10, 15, 20, 25, 30, 40, 50, 100].forEach(v => {
            grid.innerHTML += `<div onclick="document.getElementById('pix-area').style.display='block'" class="glass" style="padding:10px; cursor:pointer; font-size:11px;"><b>R$ ${v}</b><br><small style="color:#bc13fe;">Gems</small></div>`;
        });

        function logar() {
            if(document.getElementById('e-adm').value === "radamez1228@gmail.com" && document.getElementById('s-adm').value === "Ra@$926629") {
                document.getElementById('log-box').style.display = 'none';
                document.getElementById('painel').style.display = 'block';
                document.getElementById('topo-saldo').innerText = "PRESIDENTE";
            }
        }

        async function liberarGems() {
            const n = document.getElementById('l-nick').value;
            const q = document.getElementById('l-qtd').value;
            await supabase.from('usuarios').upsert({ apelido: n, gems: q }, { onConflict: 'apelido' });
            alert("GEMS LIBERADAS!");
        }

        async function start(modo) {
            try {
                await client.join(appId, "canal-pixxx", null, null);
                tracks.a = await AgoraRTC.createMicrophoneAudioTrack();
                tracks.v = modo === 'camera' ? await AgoraRTC.createCameraVideoTrack() : await AgoraRTC.createScreenVideoTrack();
                tracks.v.play("video-player");
                await client.publish([tracks.a, tracks.v]);
                alert("VOCÊ ESTÁ AO VIVO!");
            } catch (e) { alert("ERRO: Ative a câmera/microfone nas configurações do seu navegador!"); }
        }

        async function assistir() {
            await client.join(appId, "canal-pixxx", null, null);
            client.on("user-published", async (u, m) => {
                await client.subscribe(u, m);
                if(m === "video") u.videoTrack.play("video-player");
            });
            alert("CONECTADO!");
        }
    </script>
</body>
</html>
