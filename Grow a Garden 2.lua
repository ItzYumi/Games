-- This file was protected using Luraph Obfuscator v14.7 [https://lura.ph/]

return (function(...)
	local j = {
			"++9U=]h!)XosmLBJ4`r",
			"+9;U=4",
			"+;^80OjHpIYj!;!j%[q+)",
			"+U1_Vd@:gT;mn<m<VXglIqh",
			"+V_!#jGPnGp",
			"9CV/SGFXU5h==",
			"9fJDQGO84I2iaEFfIfFl=",
			"+Gq++C%<",
			"+VrboJ;We",
			"9ARQ4lW/4C4w8r+70rvwOfC7ajA/oP1==",
			"+\'fCG^Vbeu_GP,;nJi>C&1rYIW4`P;;4:LeO",
			"+-?TQ]_-",
			"9jyXRryxeP9/sbCIRfAfYPF8src/vdyDBQltyZs==",
			"+-?T9(",
			"9fO8tfZ==",
			"9GJ/DfyIRrFUofs==",
			"94yXRr8w0rzZ=",
		};
	for n, L in ipairs({ { 1, 17 }, { 1, 3 }, { 4, 17 } }) do
		while L[1] < L[2] do
			j[L[1]], j[L[2]], L[1], L[2] = j[L[2]], j[L[1]], L[1] + 1, L[2] - 1;
		end;
	end;
	local function n(n)
		return j[n + 33128];
	end;
	do
		local n = string.char;
		local L = string.len;
		local h = j;
		local G = math.floor;
		local y = string.sub;
		local D = {
				q = 15,
				["5"] = 30,
				["9"] = 50,
				["4"] = 18,
				u = 63,
				["1"] = 32,
				Y = 57,
				x = 12,
				["6"] = 59,
				n = 62,
				i = 8,
				j = 26,
				K = 14,
				["+"] = 39,
				U = 37,
				k = 35,
				p = 60,
				Q = 21,
				M = 44,
				a = 51,
				d = 19,
				F = 38,
				I = 13,
				["2"] = 3,
				S = 41,
				N = 31,
				W = 36,
				o = 46,
				P = 11,
				g = 10,
				y = 7,
				V = 53,
				H = 43,
				["0"] = 47,
				f = 25,
				A = 22,
				m = 40,
				X = 17,
				t = 45,
				s = 48,
				Z = 16,
				L = 49,
				["7"] = 9,
				r = 28,
				v = 34,
				J = 6,
				b = 24,
				e = 58,
				T = 42,
				G = 27,
				O = 54,
				["8"] = 5,
				["/"] = 61,
				l = 20,
				z = 55,
				h = 0,
				B = 4,
				D = 33,
				w = 1,
				C = 23,
				R = 52,
				c = 2,
				E = 29,
				["3"] = 56,
			};
		local c = type;
		local Y = table.insert;
		local X = {
				a = 9,
				V = 37,
				N = 72,
				s = 21,
				p = 7,
				["("] = 52,
				["4"] = 15,
				E = 82,
				I = 49,
				["\""] = 64,
				d = 69,
				["#"] = 20,
				["2"] = 67,
				C = 76,
				D = 50,
				["?"] = 55,
				q = 10,
				[")"] = 17,
				["!"] = 75,
				f = 48,
				t = 46,
				n = 51,
				B = 13,
				["*"] = 42,
				u = 47,
				["&"] = 5,
				["+"] = 27,
				c = 58,
				Y = 77,
				b = 8,
				T = 40,
				["$"] = 54,
				P = 65,
				["9"] = 38,
				["\\"] = 43,
				o = 14,
				j = 33,
				l = 71,
				["."] = 0,
				L = 73,
				S = 32,
				W = 80,
				["6"] = 70,
				G = 36,
				["<"] = 60,
				["^"] = 26,
				A = 19,
				["%"] = 34,
				[":"] = 41,
				["0"] = 16,
				["8"] = 79,
				[";"] = 31,
				m = 23,
				U = 29,
				g = 83,
				Q = 53,
				X = 62,
				Z = 78,
				["\'"] = 39,
				["3"] = 44,
				h = 24,
				k = 6,
				["1"] = 28,
				["["] = 18,
				J = 11,
				i = 1,
				["5"] = 2,
				F = 56,
				[">"] = 57,
				["7"] = 81,
				["-"] = 30,
				r = 63,
				R = 66,
				["="] = 45,
				[","] = 3,
				["/"] = 61,
				K = 12,
				M = 22,
				["`"] = 68,
				_ = 35,
				H = 74,
				["]"] = 59,
				["@"] = 25,
				e = 84,
				O = 4,
			};
		local e = table.concat;
		for j = 1, #h, 1 do
			local O = h[j];
			if c(O) == "string" then
				local c = y(O, 1, 1);
				if c == "9" then
					O = y(O, 2);
					local c = L(O);
					local X = {};
					local p = 1;
					local w = 0;
					local R = 0;
					while p <= c do
						local j = y(O, p, p);
						local L = D[j];
						if L then
							w = w + L * (64 ^ ((3 - R)));
							R = R + 1;
							if R == 4 then
								R = 0;
								local j = G(w / 65536);
								local L = G((w % 65536) / 256);
								local h = w % 256;
								Y(X, n(j, L, h));
								w = 0;
							end;
						elseif j == "=" then
							Y(X, n(G(w / 65536)));
							if p >= c or y(O, p + 1, p + 1) ~= "=" then
								Y(X, n(G((w % 65536) / 256)));
							end;
							break;
						end;
						p = p + 1;
					end;
					h[j] = e(X);
				elseif c == "+" then
					O = y(O, 2);
					local D = L(O);
					local c = {};
					local p = 1;
					while p <= D do
						local j = (D - p) + 1;
						local L = j >= 5 and 5 or j;
						local h = 0;
						local e = L > 1;
						for j = 0, 4, 1 do
							local n;
							if j < L then
								local L = y(O, p + j, p + j);
								n = X[L];
								if not n then
									e = false;
									break;
								end;
							else
								n = 84;
							end;
							h = h * 85 + n;
						end;
						if e then
							local j = G(h / 16777216) % 256;
							local y = G(h / 65536) % 256;
							local D = G(h / 256) % 256;
							local X = h % 256;
							if L == 5 then
								Y(c, n(j, y, D, X));
							elseif L == 4 then
								Y(c, n(j, y, D));
							elseif L == 3 then
								Y(c, n(j, y));
							elseif L == 2 then
								Y(c, n(j));
							end;
						end;
						p = p + L;
					end;
					h[j] = e(c);
				end;
			end;
		end;
	end;
	return (function(Y, D, c, j, y, G, h, O, e, p, T, X, L, i, N, w, R)
		X, w, R, L, e, i, T, O, p, N = {}, function(j)
				for n = 1, #j, 1 do
					e[j[n]] = 1 + e[j[n]];
				end;
				if G then
					local L = G(true);
					local h = D(L);
					h[n(-33119)], h[n(-33111)], h[n(-33113)] = j, R, function()
							return -408423;
						end;
					return L;
				else
					return y({}, { [n(-33111)] = R, [n(-33119)] = j, [n(-33113)] = function()
							return -408423;
						end });
				end;
			end, function(j)
				local n, L = 1, j[1];
				while L do
					e[L], n = e[L] - 1, 1 + n;
					if 0 == e[L] then
						e[L], X[L] = nil, nil;
					end;
					L = j[n];
				end;
			end, function(L, G, y, D)
				local w, p, B, R, e, Y, k, U, t, S, a, N, K, H;
				while L do
					if 5964303 > L then
						if L < 4035399 then
							if L < 1192012 then
								L, e = n(-33112), G;
								p = O();
								X[p] = L;
								Y, L = n(-33117), n(-33114);
								w = O();
								X[w] = L;
								L = j[Y];
								N = i(11042069, { p, w });
								t = { L(N) };
								R, Y = t[2], t[1];
								N = Y;
								L = N and 11929534 or 5082515;
								Y = N;
							elseif L < 2835277 then
								t = B();
								L = 7765152;
							else
								S, a, K = n(-33123), n(-33121), n(-33120);
								t = j[S];
								L = 7765152;
								U = j[K];
								K = U(H);
								k = a .. K;
								S = t(k);
							end;
						else
							if L < 4691280 then
								L, Y, B = nil, nil, n(-33126);
								X[w] = L;
								X[p] = Y;
								t = j[B];
								S = { t(R) };
								H = S[2];
								B = S[1];
								L = B and 1899803 or 3770752;
							else
								L = Y and 4300046 or 11315120;
							end;
						end;
					else
						if L < 11178594 then
							if 7305621 > L then
								p = T(p);
								L, Y, R = j[n(-33118)], {}, nil;
								w = T(w);
								N = nil;
							elseif 9403610 > L then
								H, L, B = nil, 6846091, nil;
							else
								e, p = n(-33127), n(-33127);
								Y = j[e];
								e = n(-33125);
								L = Y[e];
								e = j[p];
								R = n(-33122);
								p = X[y[1]];
								w = X[y[2]];
								Y = { L(e, p, w, R) };
								Y, L = { h(Y) }, j[n(-33124)];
							end;
						else
							if L < 11622327 then
								B, L, H = n(-33123), 6846091, n(-33115);
								t = j[B];
								B = t(H);
							else
								L, Y = 5082515, R;
							end;
						end;
					end;
				end;
				L = #D;
				return h(Y);
			end, {}, function(j, n)
				local h = w(n);
				local G = function(G)
						return L(j, { G }, n, h);
					end;
				return G;
			end, function(j)
				e[j] = e[j] - 1;
				if e[j] == 0 then
					e[j], X[j] = nil, nil;
				end;
			end, function()
				p = p + 1;
				e[p] = 1;
				return p;
			end, 0, function(j, n)
				local h = w(n);
				local G = function(...)
						return L(j, { ... }, n, h);
					end;
				return G;
			end;
		return (N(484221, {}))(h(Y));
	end)({ ... }, getmetatable, select, getfenv and getfenv() or _ENV, setmetatable, newproxy, unpack or table[n(-33116)]);
end)(...);
