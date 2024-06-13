using System.Collections;
using System.Collections.Generic;
using Ink.Runtime;
using TMPro;
using UnityEngine;
using Random = UnityEngine.Random;

public class DialogueManager : MonoBehaviour
{
    [Header("Params")] 
    [SerializeField] private float typingSpeed = 0.04f;
    
    [Header("Dialogue UI")] 
    [SerializeField] private GameObject dialoguePanel;
    [SerializeField] private GameObject continueIcon;
    [SerializeField] private TextMeshProUGUI dialogueText;
    [SerializeField] private TextMeshProUGUI displayNameText;
    [SerializeField] private Animator portraitAnimator;
    private Animator _layoutAnimator;

    [Header("Choices UI")] 
    [SerializeField] private GameObject[] choices;
    private TextMeshProUGUI[] _choicesText;

    [Header("Audio")] 
    [SerializeField] private DialogueAudioInfoSO defaultAudioInfo;
    [SerializeField] private DialogueAudioInfoSO[] audioInfos;
    [SerializeField] private bool makePredictable;
    private DialogueAudioInfoSO _currentAudioInfo;
    private Dictionary<string, DialogueAudioInfoSO> _audioInfoDictionary;
    private AudioSource _audioSource;

    private Story _currentStory;
    public bool dialogueIsPlaying { get; private set; }
    public bool dialogueIsEnding { get; private set; }

    private bool canContinueToNextLine = false;

    private Coroutine displayLineCoroutine;

    private static DialogueManager _instance;

    private const string SPEAKER_TAG = "speaker";
    private const string PORTRAIT_TAG = "portrait";
    private const string LAYOUT_TAG = "layout";
    private const string AUDIO_TAG = "audio";
    private const string ENDING_TAG = "ending";

    private void Awake()
    {
        if (_instance != null)
        {
            Debug.LogWarning("Found more than one Dialogue Manager in the scene");
        }

        _instance = this;

        _audioSource = this.gameObject.AddComponent<AudioSource>();
        _currentAudioInfo = defaultAudioInfo;
    }

    public static DialogueManager GetInstance()
    {
        return _instance;
    }

    private void Start()
    {
        dialogueIsPlaying = false;
        dialoguePanel.SetActive(false);

        _layoutAnimator = dialoguePanel.GetComponent<Animator>();
        
        // получаем все выборы из текста
        _choicesText = new TextMeshProUGUI[choices.Length];
        int index = 0;
        foreach (GameObject choice in choices)
        {
            _choicesText[index] = choice.GetComponentInChildren<TextMeshProUGUI>();
            index++;
        }
        
        InitializeAudioInfoDictionary();
    }

    private void InitializeAudioInfoDictionary()
    {
        _audioInfoDictionary = new Dictionary<string, DialogueAudioInfoSO>();
        _audioInfoDictionary.Add(defaultAudioInfo.id, defaultAudioInfo);

        foreach (DialogueAudioInfoSO audioInfo in audioInfos)
        {
            _audioInfoDictionary.Add(audioInfo.id, audioInfo);
        }
    }

    private void SetCurrentAudioInfo(string id)
    {
        DialogueAudioInfoSO audioInfo = null;
        _audioInfoDictionary.TryGetValue(id, out audioInfo);
        if (audioInfo != null)
        {
            this._currentAudioInfo = audioInfo;
        }
        else
        {
            Debug.Log("Failed to find audio info for id:" + id);
        }
    }
    
    private void Update()
    {
        if (!dialogueIsPlaying)
        {
            return;
        }

        if (canContinueToNextLine
            && _currentStory.currentChoices.Count == 0 
            && InputManager.GetInstance().GetInteractPressed())
        {
            ContinueStory();
        }
    }

    public void EnterDialogueMode(TextAsset inkJSON)
    {
        _currentStory = new Story(inkJSON.text);
        dialoguePanel.SetActive(true);
        dialogueIsPlaying = true;
        //PauseGame.GetInstance().Pause(dialoguePanel);

        displayNameText.text = "???";
        portraitAnimator.Play("default");
        _layoutAnimator.Play("right");

        ContinueStory();
    }

    public void ExitDialogueMode()
    {
        dialogueIsPlaying = false;
        dialoguePanel.SetActive(false);
        //PauseGame.GetInstance().Resume(dialoguePanel);
        dialogueText.text = "";
        
        SetCurrentAudioInfo(defaultAudioInfo.id);
    }

    private void ContinueStory()
    {
        if (_currentStory.canContinue)
        {
            if (displayLineCoroutine != null)
            {
                StopCoroutine(displayLineCoroutine);
            }

            string nextLine = _currentStory.Continue();
            HandleTags(_currentStory.currentTags);
            displayLineCoroutine = StartCoroutine(DisplayLine(nextLine));
        }
        else
        {
            ExitDialogueMode();
        }
    }

    private IEnumerator DisplayLine(string line)
    {
        dialogueText.text = line;
        dialogueText.maxVisibleCharacters = 0;
        
        continueIcon.SetActive(false);
        HideChoices();
        canContinueToNextLine = false;

        bool isAddingRichTextTag = false;

        foreach (char letter in line.ToCharArray())
        {
            if (InputManager.GetInstance().GetSubmitPressed())
            {
                dialogueText.maxVisibleCharacters = line.Length;
                break;
            }

            if (letter == '<' || isAddingRichTextTag)
            {
                isAddingRichTextTag = true;
                if (letter == '>')
                {
                    isAddingRichTextTag = false;
                }
            }
            else
            {
                PlayDialogueSound(dialogueText.maxVisibleCharacters, dialogueText.text[dialogueText.maxVisibleCharacters]);
                dialogueText.maxVisibleCharacters++;
                yield return new WaitForSeconds(typingSpeed);
            }
        }
        
        continueIcon.SetActive(true);
        DisplayChoices();
        canContinueToNextLine = true;
    }

    private void PlayDialogueSound(int currentDisplayedCharacterCount, char currentCharacter)
    {
        AudioClip[] dialogueTypingSoundClips = _currentAudioInfo.dialogueTypingSoundClips;
        int frequencyLevel = _currentAudioInfo.frequencyLevel;
        float minPitch = _currentAudioInfo.minPitch;
        float maxPitch = _currentAudioInfo.maxPitch;
        bool stopAudioSource = _currentAudioInfo.stopAudioSource;
        
        if (currentDisplayedCharacterCount % frequencyLevel == 0)
        {
            if (stopAudioSource)
            {
                _audioSource.Stop();
            }

            AudioClip soundClip = null;

            if (makePredictable)
            {
                int hashCode = currentCharacter.GetHashCode();
                
                int predictableIndex = hashCode % dialogueTypingSoundClips.Length;
                soundClip = dialogueTypingSoundClips[predictableIndex];

                int minPitchInt = (int)(minPitch * 100);
                int maxPitchInt = (int)(maxPitch * 100);
                int pitchRangeInt = maxPitchInt - minPitchInt;

                if (pitchRangeInt != 0)
                {
                    int predictablePitchInt = (hashCode % pitchRangeInt) + minPitchInt;
                    float predictablePitch = predictablePitchInt / 100f;
                    _audioSource.pitch = predictablePitch;
                }
                else
                {
                    _audioSource.pitch = minPitch;
                }
            }
            else
            {
                int randomIndex = Random.Range(0, dialogueTypingSoundClips.Length);
                soundClip = dialogueTypingSoundClips[randomIndex];
                _audioSource.pitch = Random.Range(minPitch, maxPitch);
            }

            _audioSource.PlayOneShot(soundClip);
        }
    }

    private void HideChoices()
    {
        foreach (GameObject choiceButton in choices)
        {
            choiceButton.SetActive(false);
        }
    }

    private void HandleTags(List<string> currentTags)
    {
        foreach (string tag in currentTags)
        {
            string[] splitTag = tag.Split(':');
            if (splitTag.Length != 2)
            {
                Debug.LogError("Tag could not be appropriately parsed: " + tag);
            }

            string tagKey = splitTag[0].Trim();
            string tagValue = splitTag[1].Trim();

            switch (tagKey)
            {
                case SPEAKER_TAG:
                    displayNameText.text = tagValue;
                    break;
                case PORTRAIT_TAG:
                    portraitAnimator.Play(tagValue);
                    break;
                case LAYOUT_TAG:
                    _layoutAnimator.Play(tagValue);
                    break;
                case AUDIO_TAG:
                    SetCurrentAudioInfo(tagValue);
                    break;
                case ENDING_TAG:
                    dialogueIsEnding = bool.Parse(tagValue);
                    break;
                default:
                    Debug.LogWarning("Tag came in but is not currently being handled: " + tag);
                    break;
            }
        }
    }
    
    private void DisplayChoices()
    {
        List<Choice> currentChoices = _currentStory.currentChoices;

        if (currentChoices.Count > choices.Length)
        {
            Debug.Log("More choices were given than the UI can support. Number of choices given: " 
                      + currentChoices.Count);
        }

        int index = 0;
        foreach (Choice choice in currentChoices)
        {
            choices[index].gameObject.SetActive(true);
            _choicesText[index].text = choice.text;
            index++;
        }

        for (int i = index; i < choices.Length; i++)
        {
            choices[i].gameObject.SetActive(false);
        }
    }

    public void MakeChoice(int choiceIndex)
    {
        if (canContinueToNextLine)
        {
            _currentStory.ChooseChoiceIndex(choiceIndex);
            InputManager.GetInstance().RegisterSubmitPressed();
            ContinueStory();
        }
    }
}
