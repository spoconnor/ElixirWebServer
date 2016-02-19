defmodule PerlinNoise do
use Bitwise

  # returns int
  # int minY, int maxY, float t
  def interpolate(minY, maxY, t) do
    u = 1 - t
    minY * u + maxY * t
  end

  # Return a width*height list of random floats between 0 and 1
  def generateWhiteNoise(width, height) do
    Array2D.new(width, height, fn -> :random.uniform end)
  end

  # Returns int[][]
  # int minY, int maxY, float[][] perlinNoise
  def mapInts(minY, maxY, perlinNoise) do
    #width = perlinNoise.Length;
    #height = perlinNoise[0].Length;
    #int[][] heightMap = GetEmptyArray<int>(width, height);
    #for (int i = 0; i < width; i++)
    #  for (int j = 0; j < height; j++)
    #    heightMap[i][j] = Interpolate(minY, maxY, perlinNoise[i][j]);
    #}
    #return heightMap;
    Enum.map(perlinNoise, fn {i} -> interpolate(minY, maxY, i) end)
  end

  def sample0(i, samplePeriod), do: div(i, samplePeriod) * samplePeriod
  def sample1(i, samplePeriod, size), do: rem( (sample0(i, samplePeriod) + samplePeriod), size) #wrap around
  def blend(i, samplePeriod, sampleFrequency), do: (i - sample0(i, samplePeriod)) * sampleFrequency

  # returns float[][]
  # float[][] baseNoise, int octave
  def generateSmoothNoise(width, height, baseNoise, octave) do
    samplePeriod = 1 <<< octave  # calculates 2 ^ k
    sampleFrequency = 1.0 / samplePeriod

    #smoothNoise = :array.new([{:size,height}, {:fixed,:true}, {:default, 
    #  :array.new([{:size,width}, {:fixed,:true}, {:default, 0}]))

    smoothNoise = Array2D.new(width,height,0)

  # calculate the horizontal sampling indices
  #0..width-1 |> iStream = Stream.map(i, &([
  iSamples = 0..width-1 |> Enum.map(&([
    &1,
    sample0(&1, samplePeriod),
    sample1(&1, samplePeriod, width),
    blend(&1, samplePeriod, sampleFrequency)
  ]))

  # calculate the horizontal sampling indices
  jSamples = 0..height-1 |> Enum.map(&([
    &1,
    sample0(&1, samplePeriod),
    sample1(&1, samplePeriod, height),
    blend(&1, samplePeriod, sampleFrequency)
  ]))

  Enum.map(iSamples, fn(i) -> 
    Enum.map(jSamples, fn(j) -> [i,j] end) end)

        # blend the top two corners
#        top = Interpolate(
#          lookup(baseNoise,iSample0,jSample0), 
#          lookup(baseNoise,iSample1,jSample0), 
#          horizontalBlend)

        # blend the bottom two corners
#        bottom = Interpolate(
#          lookup(baseNoise,iSample0,jSample1), 
#          lookup(baseNoise,iSample1,jSample1), 
#          horizontalBlend)

        # final blend
#        smoothNoise[i][j] = Interpolate(top, bottom, verticalBlend)
#      )
#    )
#    return smoothNoise
  end

  def blend([p1|perlinNoise], [o1|octaveNoise], amplitude, result) do
    blend(perlinNoise, octaveNoise, amplitude, result ++ [p1 + o1 * amplitude])
  end
  def blend([], [], amplitude, result) do
    result
  end

  # returns float[][] 
  # float[][] baseNoise, int octaveCount
  def generatePerlinNoise(width, height, baseNoise, octaveCount) do
    smoothNoise = Array2D.new(0,0,0) # float[octaveCount][][]; #an array of 2D arrays containing
    PERSISTANCE = 0.4

    # generate smooth noise
    octaves = [0..(octaveCount-1)]
    smoothNoise = Enum.map(octaves, fn (octave) -> generateSmoothNoise(width,height, baseNoise, octave) end)

    perlinNoise = Array2D.new(width,height,0)

    amplitude = 1.0
    totalAmplitude = 0.0

    # blend noise together
    Enum.map(smoothNoise, fn (octaveNoise) -> 
      amplitude = amplitude * PERSISTANCE
      totalAmplitude = totalAmplitude + amplitude
      perlinNoise = blend(perlinNoise, octaveNoise, amplitude, [])
    end)

    # normalisation
    normalizedPerlinNoise = Enum.map(perlinNoise, fn {i} -> i / totalAmplitude end)
  end

  #--------------------------------------------------------------------------

  # seed if of the form {1420, 706537, 145248}
  def seedRandom(seed) do
    :random.seed(seed)
  end

  def seedRandom() do
    :random.seed(:erlang.now)
  end

  # returns int[][] 
  # int width, int height, int minY, int maxY, int octaveCount
  def getIntMap(width, height, minY, maxY, octaveCount) do
    baseNoise = generateWhiteNoise(width, height)
    perlinNoise = generatePerlinNoise(width, height, baseNoise, octaveCount)
    mapInts(minY, maxY, perlinNoise)
  end

  #--------------------------------------------------------------------------
end
