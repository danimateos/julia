### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 986904d4-55ab-11eb-1ef0-4360274aa96c
begin
	using Plots
	using BenchmarkTools
	using PlutoUI
	using Pipe
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
			agent.position = boundary_condition(new_position, L)
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
		     ylims=(-simulation.L - 1, simulation.L + 1), 
			 legend=false)
		
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
		
		diagnostics = Vector{Simulation}(undef, steps ÷ checkpoints)
		
		for i in 1:steps
			if i % checkpoints == 0
				diagnostics[i ÷ checkpoints] = deepcopy(simulation)
			end

			step!(simulation)
		end
			
		diagnostics
	end
end

# ╔═╡ 5c279db4-55a6-11eb-142f-c70ad5a29aef
begin
	n_steps = 10000
	s = Simulation(0.2, 3, 200, 20)
	p1 = visualize(s)
	
	results = run!(s, 10000, 1)
	
	
	p2 = visualize(s)
	
	plot(p1, p2)
end
	

# ╔═╡ b0aa6d80-55b5-11eb-37a7-add5447a71b5
@bind i Slider(1:length(results), show_value=true)

# ╔═╡ 5a6cf3b8-55b8-11eb-12c7-05752389d032
visualize(results[i])

# ╔═╡ 23b7dc8a-55c6-11eb-0ff5-a704c61ac771
function run_n(n :: Integer, n_steps, D :: AbstractFloat, enzymes :: Number, substrates :: Number, L :: Number)
	
	results = Array{Simulation, 2}(undef, (n_steps, n))
	
	for i in 1:n
		s = Simulation(D, enzymes, substrates, L)
		this_one = run!(s, n_steps, 1)
		
		results[:, i] = this_one
	end
	results
end

# ╔═╡ dfebfbe0-55c9-11eb-2791-a578271fbcf5
md"Would you like to run many simulations? It takes a while $(@bind run_many CheckBox())"

# ╔═╡ 87df4954-55b6-11eb-1703-f93170ccdfdc
function fraction_B(simulation :: Simulation)
	mean(@pipe simulation.agents |> filter(a -> isa(a, Substrate), _) |> map(s -> s.state == B ? 1 : 0, _))
end

# ╔═╡ 97195298-55c7-11eb-307f-cfdebaf1190c
begin
	test = run_n(10, 20000, 0.2, 3, 200, 20)
	
	data = fraction_B.(test)
	p = plot(data, alpha=.5, legend=false)
	plot!(mean.(eachrow(data)), linewidth=3)
end

# ╔═╡ d8ac9566-55c8-11eb-123d-fdb5e4baf4d6
mean.(eachrow(fraction_B.(test)))

# ╔═╡ 745e95aa-55b9-11eb-2537-252476fe9e50
md"Would you like to make an animation? It takes a while $(@bind animate CheckBox())"

# ╔═╡ 2d62d01e-55b7-11eb-0143-85acc8244b8b
begin
	if animate
		animation = @animate for sim in results visualize(sim) end
		gif(animation, "anim_fps30.gif", fps = 24)
	end
end

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
# ╠═b0aa6d80-55b5-11eb-37a7-add5447a71b5
# ╠═5a6cf3b8-55b8-11eb-12c7-05752389d032
# ╠═23b7dc8a-55c6-11eb-0ff5-a704c61ac771
# ╠═dfebfbe0-55c9-11eb-2791-a578271fbcf5
# ╠═97195298-55c7-11eb-307f-cfdebaf1190c
# ╠═d8ac9566-55c8-11eb-123d-fdb5e4baf4d6
# ╟─87df4954-55b6-11eb-1703-f93170ccdfdc
# ╠═745e95aa-55b9-11eb-2537-252476fe9e50
# ╠═2d62d01e-55b7-11eb-0143-85acc8244b8b
# ╟─9ae8fd58-557a-11eb-3371-918f50f832fb
