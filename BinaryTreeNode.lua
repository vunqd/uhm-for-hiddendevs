function DataService:Award(Player, Reward, HasLeft, HomeScore, AwayScore, Opponent, MyTeam)
	

	local PlayerInstance = Players:FindFirstChild(Player)

	if PlayerInstance then
		local FindUserData = self:FetchProfileData(PlayerInstance)
		if FindUserData then
			
			FindUserData = FindUserData.Data
			
			local FindCourtInformation = DataService.CourtInformation[PlayerInstance.Court.Value]
			if FindCourtInformation then
				local PlayersTeam = FindCourtInformation.HomePlayers.Players[Player] and '_Home' or '_Away'

				local MyTeamMMR = PlayersTeam == '_Home' and FindCourtInformation.HomePlayers.MMR
					or FindCourtInformation.AwayPlayers.MMR

				local OpponentTeamMMR = PlayersTeam == '_Home' and FindCourtInformation.AwayPlayers.MMR 
					or FindCourtInformation.HomePlayers.MMR

				
				
				local LPReductionCalculation = math.ceil(self:CalculateChange(Reward, MyTeamMMR, OpponentTeamMMR))
				
				local FindCourt = self.CourtService.Courts[PlayerInstance.Court.Value]

				
				if Reward == 'Loss' and not HasLeft then
				
					ReplicatedStorage.Events.ForgetMatch:FireClient(PlayerInstance)
					local Connection, PlayerRemovingConnection
					
					PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(Player)
						if Player == PlayerInstance then
							self:UpdateClass(FindUserData, LPReductionCalculation, Reward, FindCourtInformation, FindCourt, PlayerInstance, HasLeft, HomeScore, AwayScore, Opponent, MyTeam)
							if Connection ~= nil then
								Connection:Disconnect()
							end
							PlayerRemovingConnection:Disconnect()
						end
					end)
					
					
					Connection = ReplicatedStorage.Events.ForgetMatch.OnServerEvent:Connect(function(Player, Decision)
						if PlayerInstance == Player then
							if Decision == 'No' then
								self:UpdateClass(FindUserData, LPReductionCalculation, Reward, FindCourtInformation, FindCourt, PlayerInstance, HasLeft, HomeScore, AwayScore, Opponent, MyTeam)
								self.PlayerService:UpdateBillboard(PlayerInstance)
							else 
								MarketService:PromptProductPurchase(PlayerInstance, Products.Single['ForgetMatch'])
								local HasPurchased
								HasPurchased = script.PurchasedProduct.Event:Connect(function(Player, DidPurchase)
									if Player == PlayerInstance.UserId then
										if not DidPurchase then 
											self:UpdateClass(FindUserData, LPReductionCalculation, Reward, FindCourtInformation, FindCourt, PlayerInstance, HasLeft, HomeScore, AwayScore, Opponent, MyTeam)
											self.PlayerService:UpdateBillboard(PlayerInstance)
										else
											WebhookService:Post(
												'Purchase',
												{Name = PlayerInstance.Name},
												{ProductID = Products.Single['ForgetMatch'], ProductName = 'Forget Match'}
											)
										end
										HasPurchased:Disconnect()
									end
								end)
							end
						end
						Connection:Disconnect()
						PlayerRemovingConnection:Disconnect()
					end)
					
				elseif Reward == 'Win' or HasLeft then
					
					if Reward == 'Win' then 
						self:UpdateClass(FindUserData, LPReductionCalculation, Reward, FindCourtInformation, FindCourt, PlayerInstance, HasLeft, HomeScore, AwayScore, Opponent, MyTeam)
					else 
						if FindUserData.Core.Safeguard > 0 then
							FindUserData.Core.Safeguard -= 1
						else 
							self:UpdateClass(FindUserData, LPReductionCalculation, Reward, FindCourtInformation, FindCourt, PlayerInstance, HasLeft, HomeScore, AwayScore, Opponent, MyTeam)
						end
					end
					
					

					

				end

			end
			
		end
		
		
		self.PlayerService:UpdateBillboard(PlayerInstance)
		
		
	end
	
	
end



function DataService:GetBestBadges(Player, Data)
	
	local FindData = Data or self:FetchProfileData(Player)
	local HolderBadges = {}
	
	if FindData then

		
		for Index, Badges in pairs(FindData.Badges) do 
			local CompactTable = {
				Name = Badges.Name, 
				Progression = Badges.Progression,
				Current = Badges.Current
			}	
			
			
			if #HolderBadges < 5 and not table.find(HolderBadges, Badges) and CompactTable.Progression > 0 then
				table.insert(HolderBadges, Badges)
				
			else 
				
				for Index2, Badges2 in pairs(HolderBadges) do 
					if CompactTable.Progression > Badges2.Progression and not table.find(HolderBadges, CompactTable) then
						
						table.remove(HolderBadges, Index2)
						table.insert(HolderBadges, CompactTable)
						
					elseif CompactTable.Progression == Badges2.Progression and 
						CompactTable.Current > Badges2.Current and not
						table.find(HolderBadges, CompactTable) and 
							CompactTable.Progression > 0 then 
						
						
						table.remove(HolderBadges, Index2)
						table.insert(HolderBadges, CompactTable)
						
							
						
					end
					
					
				end
				
				
			end
		
			
		end
		
	end
	
	
	return HolderBadges
	
end

function DataService:TotalMMR(MMRTable)
	
	local CurrentMMR = 0
	
	for _, Username in pairs(MMRTable) do 
		
		local FindUserData = self:FetchProfileData(Players:FindFirstChild(Username))
		if FindUserData then
			
			CurrentMMR += FindUserData.Data.Class.MatchmakingRating
			
		end
		
	end
	
	return CurrentMMR
	
	
end


function DataService:SetupCourtSeries(CourtPackage, AllPlayers)
	
	local _Home = {}
	local _Away = {}
	
	for _, Users in pairs(AllPlayers['_Home']) do 
		table.insert(_Home, Users)
	end
	
	for _, Users in pairs(AllPlayers['_Away']) do 
		table.insert(_Away, Users)
	end
	
	DataService.CourtInformation[CourtPackage] = {
		
		HomePlayers = {
			Players = _Home;
			MMR = self:TotalMMR(AllPlayers['_Home'])
		};
		
		AwayPlayers = {
			Players = _Away;
			MMR = self:TotalMMR(AllPlayers['_Away'])
		};

		PackageType = CourtPackage.Parent.Name;
		
		
	}
	
	
	
end
