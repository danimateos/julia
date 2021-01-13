### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 986904d4-55ab-11eb-1ef0-4360274aa96c
begin
	using Plots
end

# ╔═╡ b71b20ca-5578-11eb-34bc-c5741fed7dd6
md"# Possibilities

* Two Component Reaction Diffusion (discretized)

* Stochastic model of regulation of gene expression

  * The repressilator

* Phase plane analysis

* Simple Michaelis Menten metabolic model

* Spatial Patterns in Biology (Dynamic Models in Biology chapter 7)

* Agent-based modelling (Dynamic Models in Biology chapter 8)

"

# ╔═╡ 63e8ffd8-5587-11eb-0f61-e7f3de62723d
md"# Agent based modelling 

Bottom-up, no math"

# ╔═╡ cfc8d6a8-5587-11eb-074d-99aa9ee3a029

md"## Simple enzymatic reaction models

The simplest possible, then elaborate:

$ A \xrightarrow{E} B$

(irreversible)

This is basically like the SIR model in the Julia course, but with two kinds of agents.
"

# ╔═╡ ea6e5730-5587-11eb-1040-39f09e0a5046
begin
	struct Coordinate
		x :: Int64
		y :: Int64
	end
	
	function Base.:+(a::Coordinate, b::Coordinate)
		Coordinate(a.x + b.x, a.y + b.y)
	end
	
	function make_tuple(c)
	 	c.x, c.y
	end
	
	possible_moves = [
	Coordinate( 0, 0), 
 	Coordinate( 1, 0), 
 	Coordinate( 0, 1), 
 	Coordinate(-1, 0), 
 	Coordinate( 0,-1)]
	
	md"### First, some definition taken from Computational Thinking hw5:"	
end

# ╔═╡ efe00666-5599-11eb-09b9-fdde2324d5be
begin
	abstract type Species end
	
	@enum State A B 
	
	mutable struct Enzyme <: Species
		D :: Float64
		position :: Coordinate
	end
	
	mutable struct Substrate <: Species
		D :: Float64
		position :: Coordinate
		state :: State
	end

	md"### Now, the agent types definitions"	
	
end

# ╔═╡ a15b7a18-5597-11eb-2fdd-152922c6a236
begin
		mutable struct Simulation
			L :: Int64
			agents :: Vector{Species}
		end
		
		function Simulation(D :: AbstractFloat, enzymes :: Number, substrates :: Number, L :: Number)
				
				agents = Vector{Species}(undef, enzymes + substrates)
			
				for i in 1:enzymes
					agents[i] = Enzyme(D, Coordinate(rand(-L:L), rand(-L:L)))
				
				end
				
				for i in (enzymes + 1) : (enzymes + substrates)
					agents[i] = Substrate(D, Coordinate(rand(-L:L), rand(-L:L)), A)
				end
			
			Simulation(L, agents)
		end
	
	md"### A wrapper `Simulation` type and its constructor"
end

# ╔═╡ 67ab912a-5599-11eb-17e3-db01fe39efa6
begin 
	function move!(agent :: Species, boundary_condition :: Function, L)
		if rand() < agent.D
			new_position = agent.position + rand(possible_moves)
			agent.position = boundary_condition(agent.position, L)
		end
	end
	
	function mirror_boundary(position :: Coordinate, L)
		
		if abs(position.x) < L & abs(position.y) < L
			return position
		end
		
		x = mirror(position.x, L)
		y = mirror(position.y, L)
		
		Coordinate(x, y)
	end
		
	function mirror(value, L)
		if value > L
			return L - (value - L)
		elseif value < -L
			return -L + (-L - value)
		end

		value
	end
				
		
	
	interact!(source :: Species, target :: Species) = Nothing
	
	function interact!(source :: Enzyme, target :: Substrate)
		if position(source) == position(target)
		   target.state = B # irreversible
		end
	end
	
	function position(species :: Species)
		species.position
	end
	
	function make_tuple(coordinate :: Coordinate)
		(coordinate.x, coordinate.y)
	end
	
	color(species :: Enzyme) = "blue"
	
	color(species :: Substrate) = species.state == A ? "grey" : "red"
	
	size(species :: Enzyme) = 2
	
	size(species :: Substrate) = 1
	
	md"### Some functions to make this all work"
end

# ╔═╡ 6e716402-55a9-11eb-1654-7d18b796097b
function visualize(simulation :: Simulation)
	
	p = plot(ratio=1, 
		     xlims=(-simulation.L - 1, simulation.L + 1), 
		     ylims=(-simulation.L - 1, simulation.L + 1))
		
	scatter!(p, make_tuple.(position.(simulation.agents)), c=color.(simulation.agents), markersize= size.(simulation.agents) .* 3)
				
end

# ╔═╡ dacf441e-55ab-11eb-182f-1b3924129fe2
begin
	function step!(simulation :: Simulation)

		move!.(simulation.agents, mirror_boundary, simulation.L)

		for source in simulation.agents, target in simulation.agents
			interact!(source, target)
		end
	end

	function run!(simulation :: Simulation, steps :: Integer, checkpoints :: Integer)
		
		for i in 1:steps
			step!(simulation)
		end
			
	end
end

# ╔═╡ 5c279db4-55a6-11eb-142f-c70ad5a29aef
begin
	s = Simulation(0.2, 3, 50, 10)
	p1 = visualize(s)
	
	run!(s, 10000, 100)
	
	p2 = visualize(s)
	
	plot(p1, p2)
end
	

# ╔═╡ 943c89ae-55a5-11eb-1931-b72c257db055
begin
	a = Substrate(1., Coordinate(19, 19), A)
	e = Enzyme(1., Coordinate(19, 19))
	
	interact!(e, a)
	
	a
end


# ╔═╡ 84d1ff4a-55ae-11eb-3431-6f7db13d4fe7
Coordinate(19, 19) == Coordinate(19, 19)

# ╔═╡ 8261fc06-55ae-11eb-2be3-1f04d18f9165


# ╔═╡ 2e8c6f44-55ae-11eb-12dd-89b91d25baa0


# ╔═╡ 113052c2-55a5-11eb-0dfc-054af6f23217


# ╔═╡ 0e72a04c-55a5-11eb-26a6-0986b84902cb


# ╔═╡ f8d51cf6-55a4-11eb-24b0-ef882d9b44b2


# ╔═╡ a3367922-5598-11eb-320d-6726d6db6473


# ╔═╡ a847e836-5595-11eb-2592-d9bd9484b24f


# ╔═╡ 66a1cf04-5587-11eb-1729-edfff1049533


# ╔═╡ 66868d98-5587-11eb-31f9-8944f20da71b


# ╔═╡ 66699104-5587-11eb-3427-791c37ab512d


# ╔═╡ 9ae8fd58-557a-11eb-3371-918f50f832fb
md"# Additional references

[Solving Systems of Stochastic PDEs and using GPUs in Julia](https://www.juliabloggers.com/solving-systems-of-stochastic-pdes-and-using-gpus-in-julia/)

[Gray Scott Model of Reaction Diffusion](https://groups.csail.mit.edu/mac/projects/amorphous/GrayScott/)

[Solving the diffusion equation in Julia](https://discourse.julialang.org/t/solving-the-diffusion-equation-in-julia/28811/5): Some performance tips from the community.


[Theoretical Biophysics - A Computational Approach - Concepts, Models, Methods and Algorithms - Reaction-diffusion](http://wwwcp.tphys.uni-heidelberg.de/biophysics/lecture_3.pdf) (PDF): Little more than a collection of equations. Written in 2020 but it's latest reference is from 2005 (!)

[Tutorials for Scientific Machine Learning and Differential Equations](https://tutorials.sciml.ai/)
"

# ╔═╡ Cell order:
# ╟─b71b20ca-5578-11eb-34bc-c5741fed7dd6
# ╟─63e8ffd8-5587-11eb-0f61-e7f3de62723d
# ╟─cfc8d6a8-5587-11eb-074d-99aa9ee3a029
# ╠═986904d4-55ab-11eb-1ef0-4360274aa96c
# ╠═ea6e5730-5587-11eb-1040-39f09e0a5046
# ╠═efe00666-5599-11eb-09b9-fdde2324d5be
# ╠═a15b7a18-5597-11eb-2fdd-152922c6a236
# ╠═67ab912a-5599-11eb-17e3-db01fe39efa6
# ╠═6e716402-55a9-11eb-1654-7d18b796097b
# ╠═dacf441e-55ab-11eb-182f-1b3924129fe2
# ╠═5c279db4-55a6-11eb-142f-c70ad5a29aef
# ╠═943c89ae-55a5-11eb-1931-b72c257db055
# ╠═84d1ff4a-55ae-11eb-3431-6f7db13d4fe7
# ╠═8261fc06-55ae-11eb-2be3-1f04d18f9165
# ╠═2e8c6f44-55ae-11eb-12dd-89b91d25baa0
# ╠═113052c2-55a5-11eb-0dfc-054af6f23217
# ╠═0e72a04c-55a5-11eb-26a6-0986b84902cb
# ╠═f8d51cf6-55a4-11eb-24b0-ef882d9b44b2
# ╠═a3367922-5598-11eb-320d-6726d6db6473
# ╠═a847e836-5595-11eb-2592-d9bd9484b24f
# ╠═66a1cf04-5587-11eb-1729-edfff1049533
# ╠═66868d98-5587-11eb-31f9-8944f20da71b
# ╠═66699104-5587-11eb-3427-791c37ab512d
# ╠═9ae8fd58-557a-11eb-3371-918f50f832fb
