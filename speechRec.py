from google.cloud import speech_v1
from google.cloud.speech_v1 import enums
import io
import os
from os.path import expanduser
import audio_metadata


#Collect all .MOV files and transform to FLAC
home = expanduser("~")

for filename in os.listdir(home + "/Desktop"):
    if (filename.endswith(".MOV")): #or .avi, .mpeg, whatever.
        mp3_filename = filename[:-4] + ".mp3"
        flac_filename = filename[:-4] + ".flac"
        monoFlac_filename = "mono" + flac_filename
        os.system("ffmpeg -i " + filename + " " + mp3_filename + " &> /dev/null")
        os.system("ffmpeg -i " + mp3_filename + " -f flac " + flac_filename + " &> /dev/null")
        os.system("ffmpeg -i " + flac_filename + " -ac 1 " + monoFlac_filename + " &> /dev/null")
    else:
        continue




def sample_recognize(local_file_path, sample_frequency):
    """
    Transcribe a short audio file using synchronous speech recognition

    Args:
      local_file_path Path to local audio file, e.g. /path/audio.wav
    """

    client = speech_v1.SpeechClient()

    # local_file_path = 'resources/brooklyn_bridge.raw'

    # The language of the supplied audio
    language_code = "en-US"

    # Sample rate in Hertz of the audio data sent
    sample_rate_hertz = sample_frequency

    # Encoding of audio data sent. This sample sets this explicitly.
    # This field is optional for FLAC and WAV audio formats.
    #encoding = enums.RecognitionConfig.AudioEncoding.MP3
    config = {
        "language_code": language_code,
        "sample_rate_hertz": sample_rate_hertz,
        "encoding": "FLAC",
    }
    with io.open(local_file_path, "rb") as f:
        content = f.read()
    audio = {"content": content}

    response = client.recognize(config, audio)
    for result in response.results:
        # First alternative is the most probable result
        alternative = result.alternatives[0]

        return "Transcript: {}".format(alternative.transcript)



for filename in os.listdir(home + "/Desktop"):
    if (filename.endswith(".flac") and filename[0:4]=="mono"):
        desired_video = home + "/Desktop/" + filename
        metadata = audio_metadata.load(desired_video)
        print(filename + " " + sample_recognize(desired_video, metadata['streaminfo']['sample_rate']))

    else:
        continue





